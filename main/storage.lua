local M = {}

local storage = {}

M.url2key = function(url)
	return tostring(url.socket) .. ":" .. tostring(url.path) .. "#" .. tostring(url.fragment)
end

M.put = function(key, value)
	storage[key] = value
end

M.get = function(key)
	local value = storage[key]
	return value
end

return M