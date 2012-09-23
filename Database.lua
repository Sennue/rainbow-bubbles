module ( ..., package.seeall )
require "sqlite3"

-- Defaults
local DEFAULT_FILENAME = "database.db"
local DEFAULT_PATH     = "./"

-- Object Metatable
local THIS_PACKAGE = package.loaded[...]
function __index ( pTable, pKey )
  return THIS_PACKAGE [ pKey ]
end

function getCopyFilenameAndPath ( pFilename, pPath, pUserDatabase )
  local filename = pFilename or DEFAULT_FILENAME
  local path     = pPath     or DEFAULT_PATH
  local copyFilename, copyPath

  -- Android
  if "Android" == MOAIEnvironment.osBrand then
    copyFilename = filename
    copyPath     = MOAIEnvironment.documentDirectory:gsub ( "/files", "/databases/" )

  -- iOS
  elseif "iOS" == MOAIEnvironment.osBrand then
    copyFilename = filename
    copyPath     = MOAIEnvironment.documentDirectory .. "/"

  -- Other
  else
    if pUserDatabase then
      copyFilename = "user_" .. filename
    else
      copyFilename = filename
    end
    copyPath = MOAIEnvironment.documentDirectory
    if copyPath then
      copyPath = copyPath .. "/"
    else
      copyPath = path
    end
  end

  return copyFilename, copyPath
end

function getCopyFilename ( pFilename, pPath, pUserDatabase )
  local copyFilename, copyPath = getCopyFilenameAndPath ( pFilename, pPath, pUserDatabase )
  return copyFilename
end

function getCopyPath ( pFilename, pPath, pUserDatabase )
  local copyFilename, copyPath = getCopyFilenameAndPath ( pFilename, pPath, pUserDatabase )
  return copyPath
end

function copy ( pFilename, pPath, pUserDatabase )
  local filename = pFilename or DEFAULT_FILENAME
  local path     = pPath     or DEFAULT_PATH
  local copyFilename, copyPath = getCopyFilenameAndPath ( pFilename, pPath, pUserDatabase )

  -- Copy
  if not ( filename == copyFilename and path == copyPath ) then
    MOAIFileSystem.copy ( copyPath .. copyFilename, path .. filename )
  end

  -- Return Filename and Path
  return copyFilename, copyPath
end

function safeCopy ( pFilename, pPath, pUserDatabase )
  local filename = pFilename or DEFAULT_FILENAME
  local path     = pPath     or DEFAULT_PATH
  local copyFilename, copyPath = getCopyFilenameAndPath ( pFilename, pPath, pUserDatabase )
  local copy

  -- Android
  if "Android" == MOAIEnvironment.osBrand then
    if not pUserDatabase or not MOAIFileSystem.checkFileExists ( copyPath .. copyFilename ) then
      copy = true
    end

  -- Not Android
  elseif pUserDatabase and not MOAIFileSystem.checkFileExists ( copyPath .. copyFilename ) then
    copy = true
  end

  -- Copy
  if copy and not ( filename == copyFilename and path == copyPath ) then
print ( "copy", copy, path .. filename, copyPath .. copyFilename )
    MOAIFileSystem.copy ( path .. filename, copyPath .. copyFilename )
  end

  -- Return Filename and Path
  return copyFilename, copyPath
end

function exec ( self, pQuery )
  self.db:exec ( pQuery )
end

function queryValue ( self, pQuery )
  local result = self.db:first_irow ( pQuery )
  return result [ 1 ]
end

function queryRows ( self, pQuery )
  local result = { }
  local i = 1
  for row in self.db:rows ( pQuery ) do
    result [ i ] = row
    i = i + 1
  end
  return result
end

function queryFirstRow ( self, pQuery )
  local result = self.db:first_row ( pQuery )
  return result
end

function prepare ( self, pQuery )
  local result = self.db:prepare ( pQuery )
  return result
end

function bindExec ( self, pStatement, pParams )
  pStatement:bind ( unpack ( pParams ) ) :exec ( )
end

function bindValue ( self, pStatement, pParams )
  local result = pStatement:bind ( unpack ( pParams ) ) :first_irow ( pQuery )
  return result [ 1 ]
end

function bindRows ( self, pStatement, pParams )
  local result = { }
  local i = 1
  for row in pStatement:bind ( unpack ( pParams ) ) :rows ( pQuery ) do
    result [ i ] = row
    i = i + 1
  end
  return result
end

function bindFirstRow ( self, pStatement, pParams )
  local result = pStatement:bind ( unpack ( pParams ) ) :first_row ( pQuery )
  return result
end

function close ( self )
  self.db:close ( )
end

function open ( pFilename, pPath, pUserDatabase )
  local result = { }
  setmetatable ( result, THIS_PACKAGE )

  result.filename, result.path = safeCopy ( pFilename, pPath, pUserDatabase )
  result.userData = pUserData
  result.db       = sqlite3.open ( result.path .. result.filename )
print ( result.filename, result.path, result.db, result.queryRows )
  return result
end

