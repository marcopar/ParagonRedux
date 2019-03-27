local M = {}

local CO = require "main.constants"
local UT = require "main.utils"

local players = { 
	{ glyph={}, sprites={}, type=CO.SETTINGS_PLAYER_TYPE_HUMAN }, 
	{ glyph={}, sprites={}, type=CO.SETTINGS_PLAYER_TYPE_HUMAN }
}

M.setType = function(player, type)
	players[player].type = type
end

M.getType = function(player)
	return players[player].type
end

M.setGlyph = function(player, glyph)
	local xmin = 0
	local ymax = 0
	if(player == CO.PLAYER1) then
		xmin = CO.PLAYER1_GRID_XMIN
		ymax = CO.PLAYER1_GRID_YMAX
	elseif(player == CO.PLAYER2) then
		xmin = CO.PLAYER2_GRID_XMIN
		ymax = CO.PLAYER2_GRID_YMAX
	end
	for i = 1, CO.GLYPH_W * CO.GLYPH_W do
		local x = xmin + ((i - 1) % CO.GLYPH_W)
		local y = ymax - math.floor((i-1) / CO.GLYPH_H)
		local tile = vmath.vector3(x, y, 0)
		UT.deleteOrb(players[player].sprites[i])
		players[player].sprites[i] = nil
		if(glyph[i] == 1) then
			players[player].sprites[i] = UT.createOrb(tile, player, 0.5)
		end
	end
	players[player].glyph = glyph
end

M.getGlyph = function(player)
	return players[player].glyph
end

M.clearGlyph = function(player)
	local xmin = 0
	local ymax = 0
	if(player == CO.PLAYER1) then
		xmin = CO.PLAYER1_GRID_XMIN
		ymax = CO.PLAYER1_GRID_YMAX
	elseif(player == CO.PLAYER2) then
		xmin = CO.PLAYER2_GRID_XMIN
		ymax = CO.PLAYER2_GRID_YMAX
	end
	for i = 1, CO.GLYPH_W * CO.GLYPH_W do
		local x = xmin + ((i - 1) % CO.GLYPH_W)
		local y = ymax - math.floor((i-1) / CO.GLYPH_H)
		local tile = vmath.vector3(x, y, 0)
		UT.deleteOrb(players[player].sprites[i])
		players[player].sprites[i] = nil
	end
	players[player].glyph = nil
end

return M