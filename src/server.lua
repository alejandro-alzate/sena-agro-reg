local http = require("http")
local https = require("https")
local pathJoin = require("luvi").path.join
local fs = require("fs")

local server = {}

local function onRequest(req, res)
	local body = os.date("%Y-%m-%d %H:%M:%S") .. "\n" .. req
	p(req, res)
	res:setHeader("Content-Type", "text/plain")
	res:setHeader("Content-Length", tostring(#res.body))
	res:finish(body)
end

function server.init()
	http.createServer(onRequest):listen(8080)
	print("Listening on port 8080")
end
