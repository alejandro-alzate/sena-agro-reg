package.path = package.path .. ";./deps/?.lua;./deps/?/init.lua;./?/init.lua"

require("class")
json = require("json")
local inventario = require("sistema.inventario")
local recordatorios = require("sistema.recordatorios")
local usuarios = require("sistema.usuarios")
