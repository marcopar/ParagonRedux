local M = {}

local C = require "main.constants"
local U = require "main.utils"

local players = { 
	{ glyph={}, sprites={} }, 
	{ glyph={}, sprites={} }
}

M.setGlyph = function(player, glyph)
	local xmin = 0
	local ymax = 0
	if(player == C.PLAYER1) then
		xmin = C.PLAYER1_GRID_XMIN
		ymax = C.PLAYER1_GRID_YMAX
	elseif(player == C.PLAYER2) then
		xmin = C.PLAYER2_GRID_XMIN
		ymax = C.PLAYER2_GRID_YMAX
	end
	for i = 1, C.GLYPH_W * C.GLYPH_W do
		local x = xmin + ((i - 1) % C.GLYPH_W)
		local y = ymax - math.floor((i-1) / C.GLYPH_H)
		local tile = vmath.vector3(x, y, 0)
		U.deleteOrb(players[player].sprites[i])
		players[player].sprites[i] = nil
		if(glyph[i] == 1) then
			players[player].sprites[i] = U.createOrb(tile, player)
		end
	end
	players[player].glyph = glyph
end

M.getGlyph = function(player)
	return players[player].glyph
end

M.setCell = function(tile, player)
	local orbPos = M.getTileCenterPosition(tile)
	local orb = factory.create("#orb_factory", orbPos, nil, nil)
	sprite.play_flipbook(orb, C.ORBS[player])	
	local cellPos = M.getCellIndexInBoard(tile)
	board.sprites[cellPos] = orb
	board.values[cellPos] = player
end

return M