production = false
package.path = package.path .. ";./?.lua;./deps/?.lua;./deps/?/init.lua;./?/init.lua;./deps/stream/?.lua"

require("class")
serpent = require("serpent")
sql = require("sqlite3")
json = require("json")
server = require("server")

p('sqlite version:', sql.version())
local db = sql.open("recursos/db/MAIN.sqlite")

server.init()
