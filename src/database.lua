local database = {}
local sql = require("sqlite3")
local sha1 = require("sha1")
local path = "recursos/db/MAIN.sqlite"
local db
database.index = {}
database.index.users = {id = 1, user = 2, contact = 3, roles = 4, salt = 5,	hash = 6}
database.index.tokens = {id = 1, owner = 2, token = 3, expires = 4}

p('sqlite version:', sql.version())

function database.init()
	db = sql.open(path)
	print("Database initialized")
end

--- Remueve comillas simples, comillas dobles y espacios
---@param str string Texto potencialmente malicioso
---@return string strsano Texto limpiado
local function escape(str)
	if str == nil then return "NULL" end
	return tostring(str):gsub("'", ""):gsub("\"", ""):gsub(" ", "")
end


function database.getUserByName(name, callback)
	local query = "select * from users where user = \"%s\""
	local fmt = string.format(query, escape(name))
	db:exec(fmt, callback)
end

function database.getOrMakeToken(username, callback)
	username = escape(username)
	local subquery = "select * from users where user = \"%s\""
	local query = "select * from tokens where owner = %d"
	local token = ""

	local subfmt = string.format(subquery, username)
	db:exec(subfmt, function (t)
		p("getOrMakeToken", t)
			local id = t[database.index.users.id]
			local fmt = string.format(query, id)
			db:exec(
				fmt,
				function (t2)
					token = t2[database.index.tokens.token]
				end,
				function()
					if token ~= "" then
						return callback(token)
					else
						local newTokenQuery = "insert into tokens (owner, token, expires) values (%d, '%s', %d);"
						local time = os.time()
						local newToken = sha1(tostring(time + 3600))
						local expires = -1 -- Sin usar aun
						local owner = id

						local fmt = string.format(newTokenQuery, owner, newToken, expires)
						p(fmt)
						db:exec(fmt, p)

						return callback(newToken)
					end
				end)
		end)
end

return database
