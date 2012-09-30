----------------------------------------------------------------
--
--  Log.lua
--  A very simple logging system.
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

local debug = false

function init ( pDebug )
  debug = pDebug
  return debug
end

function print ( ... )
  if debug then _G.print ( ... ) end
end

