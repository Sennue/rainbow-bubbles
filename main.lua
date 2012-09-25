require "ProgramState"
require "Database"
require "Log"

ProgramState.initialize ( )

-- Program Settings
local title     = "Rainbow Bubbles"
local fps       = 60
local debug     = true
local landscape = true
local portrait  = not landscape
local state     = ProgramState.new ( title, landscape, portrait, fps, debug )

function testDb ( pDb, pWrite )
  local query, row, next_id, stmt

  query = "SELECT * FROM dummy"
  row   = pDb:queryRows ( query )
  Log.print ( query, row, row [ 1 ] .id )
  row   = pDb:queryFirstRow ( query )
  Log.print ( query, row, row.id )

  query   = "SELECT * FROM dummy_view"
  next_id = pDb:queryValue ( query )
  Log.print ( query, next_id )

  if pWrite then
    query = "INSERT INTO dummy ( id, name, amount ) VALUES ( ?, 'insert', ? )"
    pDb:exec ( query:gsub ( "?", next_id ) )
    stmt  = pDb:prepare ( query )
    pDb:bindExec ( stmt, { next_id + 1, next_id + 1 } )

    query = "SELECT * FROM dummy_view"
    row   = pDb:queryValue ( query )
    Log.print ( query, row )
  end

  query = "SELECT * FROM dummy WHERE ?=id"
  stmt  = pDb:prepare ( query )
  row   = pDb:bindRows ( stmt, { 2 } )
  Log.print ( query, row, row [ 1 ] .id )
  row   = pDb:bindFirstRow ( stmt, { 2 } )
  Log.print ( query, row, row.id )

  query = "SELECT COUNT ( * ) FROM dummy_view WHERE ?=id"
  stmt  = pDb:prepare ( query )
  row   = pDb:bindValue ( stmt, { next_id } )
  Log.print ( query, row, row )
end

-- Main Loop
function loop ( pProgramState )
  -- Splash Screens

  Log.print ( "--- SYSTEM DB ---" )
  testDb ( state.systemDb, false )
  Log.print ( "--- USER DB ---" )
  testDb ( state.userDb,   true  )

  while not pProgramState.done do
    -- Loop
    state:exit ( )
  end
  state:exit ( )
end

-- Start Program
mainThread = MOAIThread.new ( )
mainThread:run ( loop, state )

