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
require "Log"
require "FullScreenImage"

-- State Variable
local mImage
local mState

-- Unload Image
function unload ( )
  if mImage then
    mImage = mImage:unload ( )
  end
end

-- Load Image
function loadImage ( )
  unload ( )
  local db         = mState.systemDb
  local query      = [[
    SELECT image FROM loading_screens WHERE ?=resolution AND ?=portrait ORDER BY RANDOM ( ) LIMIT 1
  ]]
  local stmt       = db:prepare ( query )
  local resolution = mState.textureResolution
  local portrait   = Database.bool ( mState.portrait )
  local params     = { resolution, portrait }
  local filename   = db:bindValue ( stmt, params )
  local result     = FullScreenImage.load ( filename )
  Log.print ( "Loading screen " .. filename )
  return result
end

-- State Loop
function loop ( )
  mState = ProgramState.getState ( )
  unload ( )
  MOAISim.clearRenderStack ( )
  mImage = loadImage ( )
  MOAISim.forceGarbageCollection ( )
  coroutine.yield ( )
end

