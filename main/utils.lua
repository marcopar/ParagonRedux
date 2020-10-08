local M = {}

local CO = require "main.constants"
local RE = require "rendercam.rendercam"
local ST = require "main.storage"

function M.getTile(pos)
	local tx = math.floor(pos.x / CO.TILE_W) + 1
	local ty = math.floor(pos.y / CO.TILE_H) + 1
	M.log("####################### " ..tx .. ", " .. ty)
	return vmath.vector3(tx, ty, 0)
end

function M.getTileCenterPosition(tile)
	local orbX = tile.x * CO.TILE_W - CO.TILE_W / 2;
	local orbY = tile.y * CO.TILE_H - CO.TILE_H / 2;
	return vmath.vector3(orbX, orbY, 1)		
end

function M.createOrb(tile, orbType, time, easing)
	local orbPos = M.getTileCenterPosition(tile)
	local orb = factory.create("#orb_factory", orbPos, nil, nil)
	sprite.play_flipbook(orb, CO.ORBS[orbType])
	if(time ~= nil) then
		if(easing == nil) then
			easing = go.EASING_OUTELASTIC
		end
		go.set_scale(0.01, orb)
		go.animate(orb, "scale", go.PLAYBACK_ONCE_FORWARD, CO.ORB_SCALE, easing, time, 0)
	end
	return orb
end

local function anim_changeOrbType_end(self, orb, property)
	local orbType = ST.get(ST.url2key(orb) .. "orbType")
	local callback = ST.get(ST.url2key(orb) .. "callback")
	sprite.play_flipbook(orb, CO.ORBS[orbType])
	go.animate(orb, property, go.PLAYBACK_ONCE_FORWARD, CO.ORB_SCALE, go.EASING_OUTELASTIC, 0.5, 0, callback)
	if(orbType == CO.FREEZED) then
		msg.post("controller:/controller", CO.SOUND_FREEZE)
	end
end

function M.changeOrbType(orb, orbType, delay, callback)
	local url = msg.url(nil, orb, nil) 
	ST.put(ST.url2key(url) .. "orbType", orbType)
	ST.put(ST.url2key(url) .. "callback", callback)
	go.animate(orb, "scale", go.PLAYBACK_ONCE_FORWARD, 0.1, go.EASING_LINEAR, 0.2, delay * 0.5, anim_changeOrbType_end)
end

function M.deleteOrb(orb)
	if(orb == nil) then
		return
	end
	go.delete(orb)
end

local function anim_deleteOrbAnimated_end(self, orb, property)
	local callback = ST.get(ST.url2key(orb) .. "callback")
	M.deleteOrb(orb)
	if(callback ~= nil) then
		callback()
	end
	msg.post("controller:/controller", CO.SOUND_VANISH)
end

-- animated delete
function M.deleteOrbAnimated(orb, delay, callback)
	local url = msg.url(nil, orb, nil)
	ST.put(ST.url2key(url) .. "callback", callback)
	go.animate(orb, "scale", go.PLAYBACK_ONCE_FORWARD, 0.1, go.EASING_LINEAR, 0.2, delay * 0.5, anim_deleteOrbAnimated_end)
end

function M.getWorldPos(x, y)
	return RE.screen_to_world_2d(x, y)		
end

function M.indexOf(table, value)
	for k,v in pairs(table) do
		if(v == value) then
			return k
		end
	end
	return -1
end

function M.log(msg) 
	print(os.clock() .. ": " .. msg )
end

return M