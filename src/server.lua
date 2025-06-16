local http = require("http")
local fs = require("fs")
local server = {}
local routes = {}
local resPath = "recursos/server/"
routes["/"] = "index.html"

local function onRequest(req, res)
	if req.method == "GET" then
		local route = routes[req.url]
		if route then
			local filePath = resPath .. route
			fs.readFile(filePath, function(err, data)
				if err then
					res:setHeader("Content-Type", "text/plain")
					res.statusCode = 404
					res:finish("File not found")
				else
					local contentType = "text/html"
					if string.match(filePath, "%.css$") then
						contentType = "text/css"
					elseif string.match(filePath, "%.js$") then
						contentType = "application/javascript"
					end
					res:setHeader("Content-Type", contentType)
					res:setHeader("Content-Length", tostring(#data))
					res:finish(data)
				end
			end)
		else
			res:setHeader("Content-Type", "text/plain")
			res.statusCode = 404
			res:finish("Route not found")
		end
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
end

return server
