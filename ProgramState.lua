----------------------------------------------------------------
--
--  ProgramState.lua
--  This module is used to initialize an app.  It also keeps
--  track of some fundamental data used by most apps.
--
--  Written in 2012 by Brendan A R Sechter <bsechter@sennue.com>
--
--  To the extent possible under law, the author(s) have
--  dedicated all copyright and related and neighboring rights
--  to this software to the public domain worldwide. This
--  software is distributed without any warranty.
--
--  You should have received a copy of the CC0 Public Domain
--  Dedication along with this software. If not, see
--  <http://creativecommons.org/publicdomain/zero/1.0/>.
--
----------------------------------------------------------------

module  ( ..., package.seeall )
require ( "Database" )
require ( "Log" )

local DEFAULT_SCREEN_SIZE   = 1024
local DEFAULT_ASPECT_RATIO  = 9 / 16
local DEFAULT_FPS           = 60
local MINIMUM_FPS           = 15
local DEFAULT_FPS_INTEGRITY = 3

local mState = { }

function getState ( )
  return mState
end

function exit ( self )
  if mState then
    mState.systemDb:close ( )
    mState.userDb:close   ( )
  end
  os.exit ( )
end

function initialize ( )
  -- Seed RNG
  math.randomseed ( os.time ( ) )
  for i = 1, 3 do
    math.random ( )
  end

  -- Initialize
  MOAIUntzSystem.initialize ( )

  -- Optimize
  io.stdout:setvbuf('no')
  MOAISim.clearLoopFlags ( )
  MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_SPIN )
  MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_SOAK )
  MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
  MOAISim.setBoostThreshold ( 0 )
  MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_LONG_DELAY )
  MOAISim.setLongDelayThreshold ( 5 )
end

function getScreenResolution ( pLandscape, pPortrait )
  -- Screen Resolution
  local defaultHorizontalResolution
  local defaultVerticalResolution
  if pLandscape then
    defaultHorizontalResolution = DEFAULT_SCREEN_SIZE
    defaultVerticalResolution   = DEFAULT_SCREEN_SIZE * DEFAULT_ASPECT_RATIO
  elseif pPortrait then
    defaultHorizontalResolution = DEFAULT_SCREEN_SIZE * DEFAULT_ASPECT_RATIO
    defaultVerticalResolution   = DEFAULT_SCREEN_SIZE
  else
    defaultHorizontalResolution = DEFAULT_SCREEN_SIZE
    defaultVerticalResolution   = DEFAULT_SCREEN_SIZE
  end
  local horizontalResolution = MOAIEnvironment.horizontalResolution or defaultHorizontalResolution
  local verticalResolution   = MOAIEnvironment.verticalResolution   or defaultVerticalResolution

  local swapValues = false
  if
    pLandscape and not pPortrait and
    not ( verticalResolution < horizontalResolution )
  then
    swapValues = true
  elseif
    pPortrait and not pLandscape and
    not ( horizontalResolution < verticalResolution )
  then
    swapValues = true
  end
  if swapValues then
    horizontalResolution, verticalResolution = verticalResolution, horizontalResolution
  end

  return horizontalResolution, verticalResolution
end

function getTextureResolution ( pDatabase, pScreenResolution, pHighResolution )
  -- Queries
  local queryHighResolution = [[
    SELECT resolution FROM texture_resolution_list WHERE ? <= resolution
    UNION SELECT resolution FROM max_texture_resolution ORDER BY resolution ASC LIMIT 1
  ]]
  local queryLowResolution = [[
    SELECT resolution FROM texture_resolution_list WHERE resolution <= ?
    UNION SELECT resolution FROM min_texture_resolution ORDER BY resolution DESC LIMIT 1
  ]]

  -- Use Correct Query
  local query
  if pHighResolution then
    query = queryHighResolution
  else
    query = queryLowResolution
  end

  -- Run Query
  local statement        = pDatabase:prepare ( query )
  local screenResolution = pScreenResolution or DEFAULT_SCREEN_SIZE
  local parameters       =  { screenResolution }
  local result           = pDatabase:bindValue ( statement, parameters )

  -- Debug Message
  Log.print ( "Using texture resolution of " .. result )

  -- Done
  return result
end

function setFPS ( pFPS )
  -- FPS
  local fps = pFPS or DEFAULT_FPS
  mState.originalFps = fps
  MOAISim.setStep ( 1 / fps )
  mState.fps = 1 / MOAISim.getStep ( )
  return mState.fps
end

function resetFPS ( )
  local fps = mState.originalFps or DEFAULT_FPS
  return setFPS ( fps )
end

function adaptFPS ( pIntegrity, pAverage )
  local integrity = pInegrity or DEFAULT_FPS_INTEGRITY
  local fps       = MOAISim.getPerformance ( )
  if pAverage then
    fps = ( fps + mState.fps ) / 2
  end
  result = math.min ( mState.fps, fps + integrity )
  result = math.max ( fps, MINIMUM_FPS )
  return setFPS ( fps )
end

function new ( pTitle, pLandscape, pPortrait, pFPS, pDebug )
  local result = { }
  mState       = result

  -- Parameters
  result.title     = pTitle or "test"
  result.debug     = pDebug or false

  -- Log
  Log.init ( result.debug )

  -- Database
  local databasePath = "./"
  local userDatabase = true
  result.userDb      = Database.open ( "user.db",   databasePath, userDatabase )
  result.systemDb    = Database.open ( "system.db", databasePath, not userDatabase )

  -- Screen Resolution
  result.landscape = pLandscape
  result.portrait  = pPortrait
  result.horizontalResolution, result.verticalResolution = getScreenResolution ( pLandscape, pPortrait )

  -- Texture Resolution
  local textureScreenResolution  = math.max ( result.horizontalResolution, result.verticalResolution )
  local textureUseHighResolution = true
  result.textureResolution = getTextureResolution ( result.systemDb, textureScreenResolution, textureUseHighResolution )

  -- Simulator Window
  MOAISim.openWindow ( result.title, result.horizontalResolution, result.verticalResolution )
  Log.print          ( result.title, result.horizontalResolution, result.verticalResolution )

  -- FPS
  setFPS ( pFPS )
  Log.print ( "Target frames per second " .. result.fps )

  -- Viewport
  local adjustHeight = pLandscape
  result.viewportSize = DEFAULT_SCREEN_SIZE
  if adjustHeight then
    result.viewportWidth  = result.viewportSize
    result.viewportHeight = math.floor ( result.viewportWidth * result.verticalResolution / result.horizontalResolution )
  else -- adjustWidth
    result.viewportHeight = result.viewportSize
    result.viewportWidth  = math.floor ( result.viewportHeight * result.horizontalResolution / result.verticalResolution )
  end
  result.viewport = MOAIViewport.new ( )
  result.viewport:setSize  ( result.horizontalResolution, result.verticalResolution )
  result.viewport:setScale ( result.viewportWidth,        result.viewportHeight )

  -- Resize Viewport
  function onEventResize ( pWidth, pHeight )
    result.viewport:setSize  ( pWidth,               pHeight )
    result.viewport:setScale ( result.viewportWidth, result.viewportHeight )
  end
  MOAIGfxDevice.setListener ( MOAIGfxDevice.EVENT_RESIZE, onEventResize )

  -- Camera
  result.camera = MOAICamera2D.new ( )

  -- Font
  result.fontName   = "unifont-5.1.20080907.ttf"
  result.fontSize   = 128
  result.glyphCache = MOAIGlyphCache.new ( )
  result.fontReader = MOAIFreeTypeFontReader.new ( )
  result.font       = MOAIFont.new ( )
  result.font:load           ( result.fontName )
  result.font:setCache       ( result.glyphCache )
  result.font:setReader      ( result.fontReader )
  result.font:setDefaultSize ( result.fontSize )

  -- Font Style
  result.textStyle = MOAITextStyle.new ( )
  result.textStyle:setFont ( result.font )
  result.textStyle:setSize ( result.fontSize )

  -- Previous Window
  result.back = false
  function onBackButtonPressed ( )
    result.back = true
    return result.back
  end
  if "Android" == MOAIEnvironment.osBrand then
    MOAIApp.setListener ( MOAIApp.BACK_BUTTON_PRESSED, onBackButtonPressed )
  end

  -- Close Program
  result.done = false

  -- Methods
  result.exit = exit

  -- Return
  return result
end

