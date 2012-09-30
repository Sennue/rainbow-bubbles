----------------------------------------------------------------
--
--  SplashScreens.lua
--  Reads splash screen list from database and crossfades
--  between splash screens.
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

module ( ..., package.seeall )
require "ProgramState"
require "Database"
require "Input"
require "Log"
require "FullScreenImage"

-- State Variables
local mDone
local mSkip
local mState
local mSplashScreens
local mCurrentImage
local mNextImage
local mImageCounter
local mDisplayTimer
local mFadeTimer
local mFadeTimerMax

-- Splash Screen List
function getSplashScreenList ( pState )
  local db    = pState.systemDb
  local query = [[
    SELECT * FROM splash_screens WHERE ?=resolution AND ?=portrait ORDER BY priority ASC
  ]]
  local stmt       = db:prepare ( query )
  local resolution = pState.textureResolution
  local portrait   = Database.bool ( pState.portrait )
  local params     = { resolution, portrait }
  local result     = db:bindRows ( stmt, params )
  Log.print ( #result .. " splash screens" )
  return result
end

-- Load Image
function loadImage ( pCounter )
  local result
  if mSplashScreens [ pCounter ] then
    result = FullScreenImage.load ( mSplashScreens [ pCounter ] .image )
    Log.print ( "Splash screen " .. mSplashScreens [ pCounter ] .image )
  else
    result = nil
  end
  return result
end

-- Update Image
function updateImage ( )
  -- Remove Old Image
  if mCurrentImage then
    mCurrentImage:unload ( )
  end

  -- Current Image
  if mNextImage then
    mCurrentImage = mNextImage
  else
    mCurrentImage = loadImage ( mImageCounter )
  end
  if mCurrentImage then
    if mSkip then
      mDisplayTimer = 0
      mFadeTimer    = math.floor ( mState.fps * mSplashScreens [ mImageCounter ] .fade_time / 2 )
    else
      mDisplayTimer = math.floor ( mState.fps * mSplashScreens [ mImageCounter ] .display_time )
      mFadeTimer    = math.floor ( mState.fps * mSplashScreens [ mImageCounter ] .fade_time )
    end
    mFadeTimerMax = mFadeTimer
    mCurrentImage.prop:setColor ( 1, 1, 1, 1 )
  else
    mDone = true
  end

  -- Next Image
  mNextImage = loadImage ( mImageCounter + 1 )
  if mNextImage then
    mNextImage.prop:setColor ( 1, 1, 1, 0 )
  end
end

-- On Touch
function onTouch ( )
  mSkip = true
  mDisplayTimer = 0
  mFadeTimer    = math.floor ( mFadeTimer    / 2 )
  mFadeTimerMax = math.floor ( mFadeTimerMax / 2 )
end

-- Initialize
function init ( )
  mDone          = false
  mSkip          = false
  mState         = ProgramState.getState ( )
  mSplashScreens = getSplashScreenList ( mState )
  mImageCounter  = 0
  mCurrentImage  = false
  mNextImage     = false
  mDisplayTimer  = 0
  mFadeTimer     = 0
  mFadeTimerMax  = 0
end

function cleanup ( )
  if mCurrentImage then
    mCurrentImage:unload ( )
  end
  if mNextImage then
    mNextImage:unload ( )
  end
end

-- Update
function update ( )
  local down, x, y = Input.poll ( )
  if down then
    onTouch ( )
  end

  if 0 < mDisplayTimer then
    mDisplayTimer = mDisplayTimer - 1
  elseif 0 < mFadeTimer then
    mFadeTimer = mFadeTimer - 1
    local alpha  = 1 - ( mFadeTimer / mFadeTimerMax )
    mNextImage.prop:setColor ( 1, 1, 1, alpha )
  else
    mImageCounter = mImageCounter + 1
    updateImage ( )
  end
  if not mNextImage then
    mDone = true
  end
end

-- Main Loop
function loop ( pProgramState )
  init ( )
  while not mDone do
    update ()
    coroutine.yield ( )
  end
  cleanup ( )
end

