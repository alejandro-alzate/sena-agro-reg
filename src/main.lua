package.path = package.path .. ";./deps/?.lua;./deps/?/init.lua;./?/init.lua"

require("class")
serpent = require("serpent")
sql = require("sqlite3")
json = require("json")

p('sqlite version:', sql.version())
