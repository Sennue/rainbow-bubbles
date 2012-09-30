----------------------------------------------------------------
--
--  Input.lua
--  Collects simple touch events.
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

-- Defaults
local DEFAULT_TOUCH_ID = "database.db"

-- Input Position
function position ( pValue )
  local x, y

  -- Touch Screen
  if MOAIInputMgr.device.touch then
    x, y  = MOAIInputMgr.device.touch:getTouch ( DEFAULT_TOUCH_ID )

  -- Mouse
  elseif MOAIInputMgr.device.pointer then
    x, y  = MOAIInputMgr.device.pointer:getLoc ( )

  -- Error
  else
    x, y = nil, nil
  end

  -- Done
  return x, y
end

-- Touch / Mouse Down
function down ( )
  local result
  
  -- Touch Screen
  if MOAIInputMgr.device.touch then
    result = MOAIInputMgr.device.touch:down ( DEFAULT_TOUCH_ID )

  -- Mouse
  elseif MOAIInputMgr.device.pointer then
    result = MOAIInputMgr.device.mouseLeft:down ( )

  -- Error
  else
    result = nil
  end

  -- done
  return result
end

-- All Input Data
function poll ( )
  local down = down ( )
  local x, y
  if down then
    x, y = position ( )
  else
    x, y = nil, nil
  end
  return down, x, y
end

