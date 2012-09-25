module ( ..., package.seeall )

local debug = false

function init ( pDebug )
  debug = pDebug
  return debug
end

function print ( ... )
  if debug then _G.print ( ... ) end
end

