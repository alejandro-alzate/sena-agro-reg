local database = require("./database")
local http = require("http")
local json = require("json")
local sha1 = require("sha1")
local fs = require("fs")
local server = {}
local resPath = "recursos/server/"

local function getContentType(filePath)
	if string.match(filePath, "%.html$") then
		return "text/html"
	elseif string.match(filePath, "%.css$") then
		return "text/css"
	elseif string.match(filePath, "%.js$") then
		return "application/javascript"
	elseif string.match(filePath, "%.json$") then
		return "application/json"
	elseif string.match(filePath, "%.png$") then
		return "image/png"
	elseif string.match(filePath, "%.jpg$") or string.match(filePath, "%.jpeg$") then
		return "image/jpeg"
	elseif string.match(filePath, "%.gif$") then
		return "image/gif"
	elseif string.match(filePath, "%.ico$") then
		return "image/x-icon"
	else
		return "text/plain"
	end
end

local function serveFile(filePath, res)
	fs.readFile(filePath, function(err, data)
		if err then
			res:setHeader("Content-Type", "text/plain")
			res.statusCode = 404
			res:finish("File not found")
		else
			local contentType = getContentType(filePath)
			res:setHeader("Content-Type", contentType)
			res:setHeader("Content-Length", tostring(#data))
			res:finish(data)
		end
	end)
end

local function directoryExists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	end
	return false
end

local function handleLogin(data, res)
	-- data contains the parsed JSON: { username: "...", password: "..." }
	local username = data.username
	local password = data.password
	p("Handle login:", data)

	if not username or not password then
		res:setHeader("Content-Type", "application/json")
		res.statusCode = 400
		res:finish('{"error": "Username and password required"}')
		return
	end

	database.getUserByName(username,
		function(t)
			local salty = password .. t[database.index.users.salt]
			local saltyHash = sha1(salty)
			local hash = t[database.index.users.hash]

			if saltyHash == hash then
				database.getOrMakeToken(username,
					function(token)
						res:setHeader("Content-Type", "application/json")
						res.statusCode = 200
						local data = string.format('{"success": true, "token": "%s", "message": "Login successful"}', token)
						res:finish(data)
					end)

			else
				res:setHeader("Content-Type", "application/json")
				res.statusCode = 401
				res:finish('{"error": "Invalid credentials"}')
			end
		end
	)
end

local function handleUsers(data, res)
	res:setHeader("Content-Type", "application/json")
	res.statusCode = 200
	res:finish('{"message": "Users endpoint called", "data": []}')
end

local function handleTokenValidation(data, res)
	local token = data.token
	print("Token validation request:", token)

	if not token then
		res:setHeader("Content-Type", "application/json")
		res.statusCode = 400
		res:finish('{"valid": false, "error": "Token required"}')
		return
	end

	-- For now, validate tokens by checking if they exist in database
	database.validateToken(token, function(isValid, username, userInfo)
		res:setHeader("Content-Type", "application/json")
		res.statusCode = 200
		if isValid then
			local userObj = string.format('{"valid": true, "user": {"user": "%s", "id": %d, "roles": "%s"}}',
				userInfo.user, userInfo.id, userInfo.roles or "")
			res:finish(userObj)
		else
			res:finish('{"valid": false, "error": "Invalid or expired token"}')
		end
	end)
end

local function handleEvents(data, res)
	print("Event logged:", data.name, data.description)
	res:setHeader("Content-Type", "application/json")
	res.statusCode = 200
	res:finish('{"success": true, "message": "Event logged"}')
end

local function parseRequestBody(req, callback)
	local body = ""

	req:on("data", function(chunk) body = body .. chunk print(chunk) end)

	req:on("end", function()
		local contentType = req.headers["content-type"] or ""

		if string.find(contentType, "application/json") then

			local success, jsonData = pcall(function()
				return json.decode(body)
			end)

			if success then
				callback(nil, jsonData, "json")
			else
				callback("Invalid JSON", nil, "json")
			end

		elseif string.find(contentType, "application/x-www-form-urlencoded") then
			local formData = {}
			for key, value in string.gmatch(body, "([^&=]+)=([^&=]+)") do
				formData[key] = value
			end
			callback(nil, formData, "form")
		else

			callback(nil, body, "raw")
		end
	end)

	req:on("error", function(err)
		callback(err, nil, nil)
	end)
end


local function api(req, res)
	print("API Called:", req.method, req.url)

	if req.method == "POST" then
		parseRequestBody(req, function(err, data, dataType)
			if err then
				res:setHeader("Content-Type", "application/json")
				res.statusCode = 400
				res:finish('{"error": "' .. err .. '"}')
				return
			end

			print("Received data:", dataType)

			local url = req.url:match("([^?]*)")

			if url == "/api/auth/login" then
				handleLogin(data, res)
			elseif url == "/api/auth/validate" then
				handleTokenValidation(data, res)
			elseif url == "/api/auth/verify" then
				handleTokenValidation(data, res)
			elseif url == "/api/users" then
				handleUsers(data, res)
			elseif url == "/api/events" then
				handleEvents(data, res)
			else
				res:setHeader("Content-Type", "application/json")
				res.statusCode = 404
				res:finish('{"error": "API endpoint not found"}')
			end
		end)
	else
		res:setHeader("Content-Type", "application/json")
		res.statusCode = 405
		res:finish('{"error": "Method not allowed"}')
	end
end

local function onRequest(req, res)
	if req.method == "GET" then
		local url = req.url:match("([^?]*)")

		url = string.gsub(url, "//+", "/")

		if url == "/" then
			serveFile(resPath .. "index.html", res)
			return
		end

		if string.sub(url, -1) == "/" then
			local dirPath = string.sub(url, 2)
			local indexPath = resPath .. dirPath .. "index.html"
			serveFile(indexPath, res)
			return
		end

		local filePath = resPath .. string.sub(url, 2) -- Remove leading slash

		fs.readFile(filePath, function(err, data)
			if not err then
				local contentType = getContentType(filePath)
				res:setHeader("Content-Type", contentType)
				res:setHeader("Content-Length", tostring(#data))
				res:finish(data)
			else
				local dirPath = filePath .. "/"
				local indexPath = filePath .. "/index.html"

				fs.readFile(indexPath, function(dirErr, dirData)
					if not dirErr then
						res:setHeader("Location", url .. "/")
						res.statusCode = 301
						res:finish("Moved Permanently")
					else
						-- Neither file nor directory exists
						res:setHeader("Content-Type", "text/plain")
						res.statusCode = 404
						res:finish("Route not found")
					end
				end)
			end
		end)
	elseif req.method == "POST" and string.sub(req.url:match("([^?]*)"), 1, 5) == "/api/" then
		api(req, res)
	else
		local body = "Server running at " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
		print("Request:", req.method, req.url)
		res:setHeader("Content-Type", "text/plain")
		res:setHeader("Content-Length", tostring(#body))
		res:finish(body)
	end
end

function server.init()
	http.createServer(onRequest):listen(8080)
	print("Listening on port 8080")
	database.init()
end

return server
