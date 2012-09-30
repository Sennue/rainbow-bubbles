----------------------------------------------------------------
--
--  FullScreenImage.lua
--  Loads and unloads full screen images.
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
require "Log"

-- Defaults
DEFAULT_FILENAME = "image.png"
DEFAULT_PATH     = "./"

-- Object Metatable
local THIS_PACKAGE = package.loaded[...]
function __index ( pTable, pKey )
  return THIS_PACKAGE [ pKey ]
end

-- Unload
function unload ( self )
  self.layer:removeProp    ( self.prop  )
  MOAISim.removeRenderPass ( self.layer )
  self.prop    = nil
  self.gfxQuad = nil
  self.layer   = nil
  return nil
end

function load ( pFileName, pPath, pUseDatabase )
  -- Parameters
  local filename    = pFileName or DEFAULT_FILENAME
  local path        = pPath     or DEFAULT_PATH
  local useDatabase = pUseDatabase or false

  -- Local Variables
  local state  = ProgramState.getState ( )
  local size   = state.viewportSize / 2
  local result = { }

  -- Layer
  result.layer = MOAILayer2D.new ( )
  result.layer:setViewport ( state.viewport )
  MOAISim.pushRenderPass   ( result.layer )

  -- GFX Quad
  result.gfxQuad = MOAIGfxQuad2D.new ( )
  result.gfxQuad:setTexture ( path .. filename )
  result.gfxQuad:setRect    ( -size, -size, size, size )

  -- Prop
  result.prop = MOAIProp2D.new ( )
  result.prop:setBlendMode ( MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA )
  result.prop:setDeck     ( result.gfxQuad )
  result.layer:insertProp ( result.prop )

  -- Metatable
  setmetatable ( result, THIS_PACKAGE )

  -- Done
  return result
end

