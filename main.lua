----------------------------------------------------------------
--
--  main.lua
--  This is the top level module that is ultimately responsible
--  for calling all the other modules in the project.
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

require "ProgramState"
require "Database"
require "Log"
require "SplashScreens"
require "Loading"

ProgramState.initialize ( )

-- Program Settings
local title     = "Rainbow Bubbles"
local fps       = 60
local debug     = true
local landscape = false
local portrait  = not landscape
local state     = ProgramState.new ( title, landscape, portrait, fps, debug )

-- Main Loop
function loop ( pProgramState )
  -- Splash Screens
  SplashScreens.loop ( )
  Loading.loop ( )

  -- Main Loop
  while not pProgramState.done do
    -- Loop
    coroutine.yield ( )
  end

  -- Exit
  state:exit ( )
end

-- Start Program
mainThread = MOAIThread.new ( )
mainThread:run ( loop, state )

