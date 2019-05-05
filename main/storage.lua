local M = {}

local storage = {}

function M.url2key(url)
	return tostring(url.socket) .. ":" .. tostring(url.path) .. "#" .. tostring(url.fragment)
end

function M.put(key, value)
	storage[key] = value
end

function M.get(key)
	local value = storage[key]
	return value
end

function M.remove(key)
	storage[key] = nil
end

function M.clear(key)
	storage = {}
end

return M