production = false
package.path = package.path .. ";./?.lua;./deps/?.lua;./deps/?/init.lua;./?/init.lua;./deps/stream/?.lua"

require("class")
serpent = require("serpent")
server = require("./server")
--                ↑ Sutileza extraña

server.init()
