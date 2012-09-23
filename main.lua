require "ProgramState"
require "Database"

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
  print ( query, row, row [ 1 ] .id )
  row   = pDb:queryFirstRow ( query )
  print ( query, row, row.id )

  query   = "SELECT * FROM dummy_view"
  next_id = pDb:queryValue ( query )
  print ( query, next_id )

  if pWrite then
    query = "INSERT INTO dummy ( id, name, amount ) VALUES ( ?, 'insert', ? )"
    pDb:exec ( query:gsub ( "?", next_id ) )
    stmt  = pDb:prepare ( query )
    pDb:bindExec ( stmt, { next_id + 1, next_id + 1 } )

    query = "SELECT * FROM dummy_view"
    row   = pDb:queryValue ( query )
    print ( query, row )
  end

  query = "SELECT * FROM dummy WHERE ?=id"
  stmt  = pDb:prepare ( query )
  row   = pDb:bindRows ( stmt, { 2 } )
  print ( query, row, row [ 1 ] .id )
  row   = pDb:bindFirstRow ( stmt, { 2 } )
  print ( query, row, row.id )

  query = "SELECT COUNT ( * ) FROM dummy_view WHERE ?=next_id"
  stmt  = pDb:prepare ( query )
  row   = pDb:bindValue ( stmt, { next_id } )
  print ( query, row, row )
end

-- Main Loop
function loop ( pProgramState )
  -- Splash Screens

  testDb ( state.userDb,   true  )
  testDb ( state.systemDb, false )

  while not pProgramState.done do
    -- Loop
    state:exit ( )
  end
  state:exit ( )
end

-- Start Program
mainThread = MOAIThread.new ( )
mainThread:run ( loop, state )

