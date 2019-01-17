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

M.remove = function(key)
	storage[key] = nil
end

M.clear = function(key)
	storage = {}
end

return M