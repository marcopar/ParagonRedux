local M = {}

local CO = require "main.constants"
local RE = require "rendercam.rendercam"
local ST = require "main.storage"

M.getTile = function(pos)
	local tx = math.floor(pos.x / CO.TILE_W) + 1
	local ty = math.floor(pos.y / CO.TILE_H) + 1
	print("####################### " ..tx .. ", " .. ty)
	return vmath.vector3(tx, ty, 0)
end

M.getTileCenterPosition = function(tile)
	local orbX = tile.x * CO.TILE_W - CO.TILE_W / 2;
	local orbY = tile.y * CO.TILE_H - CO.TILE_H / 2;
	return vmath.vector3(orbX, orbY, 1)		
end

M.createOrb = function(tile, orbType, time, easing)
	local orbPos = M.getTileCenterPosition(tile)
	local orb = factory.create("#orb_factory", orbPos, nil, nil)
	sprite.play_flipbook(orb, CO.ORBS[orbType])
	if(time ~= nil) then
		if(easing == nil) then
			easing = go.EASING_OUTELASTIC
		end
		go.set_scale(0.01, orb)
		go.animate(orb, "scale", go.PLAYBACK_ONCE_FORWARD, 1, easing, time, 0)
	end
	return orb
end

local function anim_changeOrbType_end(self, orb, property)
	local orbType = ST.get(ST.url2key(orb) .. "orbType")
	local callback = ST.get(ST.url2key(orb) .. "callback")
	sprite.play_flipbook(orb, CO.ORBS[orbType])
	go.animate(orb, property, go.PLAYBACK_ONCE_FORWARD, 1, go.EASING_OUTELASTIC, 0.5, 0, callback)
end

M.changeOrbType = function(orb, orbType, delay, callback)
	local url = msg.url(nil, orb, nil) 
	ST.put(ST.url2key(url) .. "orbType", orbType)
	ST.put(ST.url2key(url) .. "callback", callback)
	go.animate(orb, "scale", go.PLAYBACK_ONCE_FORWARD, 0.1, go.EASING_LINEAR, 0.2, delay * 0.5, anim_changeOrbType_end)
end

M.deleteOrb = function(orb)
	if(orb == nil) then
		return
	end
	go.delete(orb)
end

M.getWorldPos = function(action) 
	local x = action.screen_x
	local y = action.screen_y
	return RE.screen_to_world_2d(x, y)		
end

return M