local http = require("http")
local server = {}
local routes = {}

routes["/"] = "index.html"

local function onRequest(req, res)
	local body = "Server running at " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
	print("Request:", req.method, req.url)
	res:setHeader("Content-Type", "text/plain")
	res:setHeader("Content-Length", tostring(#body))
	res:finish(body)
end

function server.init()
	http.createServer(onRequest):listen(8080)
	print("Listening on port 8080")
end

return server
