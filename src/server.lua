local http = require("http")
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

local function onRequest(req, res)
	if req.method == "GET" then
		-- Remove query parameters for route matching
		local url = req.url:match("([^?]*)")

		-- Normalize URL - remove double slashes, etc.
		url = string.gsub(url, "//+", "/")

		-- Handle root case
		if url == "/" then
			serveFile(resPath .. "index.html", res)
			return
		end

		-- Check if URL ends with / (directory request)
		if string.sub(url, -1) == "/" then
			-- Apache-like behavior: serve index.html from directory
			local dirPath = string.sub(url, 2) -- Remove leading slash
			local indexPath = resPath .. dirPath .. "index.html"
			serveFile(indexPath, res)
			return
		end

		-- Check if it's a direct file request
		local filePath = resPath .. string.sub(url, 2) -- Remove leading slash

		-- Try to serve the file directly first
		fs.readFile(filePath, function(err, data)
			if not err then
				-- File exists, serve it
				local contentType = getContentType(filePath)
				res:setHeader("Content-Type", contentType)
				res:setHeader("Content-Length", tostring(#data))
				res:finish(data)
			else
				-- File doesn't exist, check if it's a directory without trailing slash
				local dirPath = filePath .. "/"
				local indexPath = filePath .. "/index.html"

				fs.readFile(indexPath, function(dirErr, dirData)
					if not dirErr then
						-- Directory with index.html exists, redirect to add trailing slash
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
	else
		-- Handle non-GET requests
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
	print("Apache-like directory serving enabled:")
	print("  / -> recursos/server/index.html")
	print("  /login/ -> recursos/server/login/index.html")
	print("  /css/main.css -> recursos/server/css/main.css")
end

return server
