local M = {}

local C = require "main.constants"
local U = require "main.utils"

local board = {sprites={}, values={}}

M.getCellIndexInBoard = function(tile)
	-- tile x, y can be negative as the tilemap is centered in the world origin, so the offset in the array can also be negative (not an issue in lua 8-))
	return tile.x + tile.y * C.BOARD_H
end

M.isOnBoard =  function(tile) 
	if(tile.x >= C.BOARD_XMIN and tile.x <= C.BOARD_XMAX and tile.y >= C.BOARD_YMIN and tile.y <=C.BOARD_YMAX) then
		return true
	end
	return false		
end

M.setCell = function(tile, player)
	local orb = U.createOrb(tile, player, 0.5)
	local cellPos = M.getCellIndexInBoard(tile)
	board.sprites[cellPos] = orb
	board.values[cellPos] = player
end

M.freezeCell = function(tile, delay, callback)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	U.changeOrbType(orb, C.FREEZED, delay, callback)
	board.values[cellPos] = C.FREEZED	
end

M.swapCell = function(tile, callback)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	local value = board.values[cellPos]
	if(value == C.PLAYER1) then
		U.changeOrbType(orb, C.PLAYER2, 0, callback)
		board.values[cellPos] = C.PLAYER2
	elseif(value == C.PLAYER2) then
		U.changeOrbType(orb, C.PLAYER1, 0, callback)
		board.values[cellPos] = C.PLAYER1
	end
end

M.clearCell = function(tile)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	U.deleteOrb(orb)
	board.sprites[cellPos] = nil
	board.values[cellPos] = nil
end

M.getCell = function(tile)
	local cellPos = M.getCellIndexInBoard(tile)
	return board.values[cellPos]
end

M.swapBoard = function(endCallback)
	local tile = vmath.vector3()
	local counters = M.getOrbCount()
	local swapped = 0
	for x = C.BOARD_XMIN, C.BOARD_XMAX do
		for y = C.BOARD_YMIN, C.BOARD_YMAX do
			tile.x = x;
			tile.y = y;
			local cellPos = M.getCellIndexInBoard(tile)
			local orb = board.sprites[cellPos]
			local value = board.values[cellPos]
			local newValue = nil
			if(value == C.PLAYER1) then
				newValue = C.PLAYER2
				swapped = swapped + 1
			elseif(value == C.PLAYER2) then
				newValue = C.PLAYER1
				swapped = swapped + 1
			end
			local callback = nil
			if(swapped == (counters.p1 + counters.p2)) then
				callback = endCallback
			end
			if(newValue ~= nil) then
				U.changeOrbType(orb, newValue, 0, callback)
				board.values[cellPos] = newValue
			end
		end
	end
end

M.clearBoard = function()
	local tile = vmath.vector3()
	for x = C.BOARD_XMIN, C.BOARD_XMAX do
		for y = C.BOARD_YMIN, C.BOARD_YMAX do
			tile.x = x;
			tile.y = y;
			M.clearCell(tile)
		end
	end
end

M.getOrbCount = function()
	local tile = vmath.vector3()
	local totalCount = 0
	local p1Count = 0
	local p2Count = 0
	local freezedCount = 0
	for x = C.BOARD_XMIN, C.BOARD_XMAX do
		for y = C.BOARD_YMIN, C.BOARD_YMAX do
			tile.x = x;
			tile.y = y;
			local cell = M.getCell(tile)
			if(cell ~= nil) then
				if(cell == C.PLAYER1) then
					p1Count = p1Count + 1
				elseif(cell == C.PLAYER2) then
					p2Count = p2Count + 1
				elseif(cell == C.FREEZED) then
					freeezedCount = freezedCount + 1
				end				
				totalCount = totalCount + 1
			end
		end
	end
	return {p1=p1Count, p2=p2Count, freezed=freezedCount, total=totalCount}
end

M.checkMatchingGlyphAtTile = function(origin, player, glyph)
	local matching = 0
	for x = 1, C.GLYPH_W do
		for y = 1, C.GLYPH_H do
			local tx = origin.x + (x - 1)
			local ty = origin.y - (y - 1)
			if(glyph[x + (y - 1) * C.GLYPH_H] == 1 and board.values[tx + ty * C.BOARD_H] == player) then
				matching = matching + 1
			end
		end
	end
	return (matching == C.GLYPH_ORBS)
end

M.checkMatchingGlyph = function(player, glyph)
	local tile = vmath.vector3()
	-- TODO maybe the original explores the board following the rows instead of columns
	-- explore from top left and match from top left as glyphs have the origin in top left
	for x = C.BOARD_XMIN, C.BOARD_XMAX - 2 do
		for y = C.BOARD_YMAX, C.BOARD_YMIN + 2, -1 do
			tile.x = x;
			tile.y = y;
			if(M.checkMatchingGlyphAtTile(tile, player, glyph)) then
				return tile
			end
		end
	end		
	return nil
end

M.freezeGlyph = function(origin, glyph, endCallback)
	local delay = 0
	for x = 1, C.GLYPH_W do
		for y = 1, C.GLYPH_H do
			local tx = origin.x + (x - 1)
			local ty = origin.y - (y - 1)
			local i = x + (y - 1) * C.GLYPH_H
			if(glyph[i] == 1) then
				local tile = vmath.vector3(tx, ty, 0)
				local callback = nil
				if(delay == (C.GLYPH_ORBS - 1)) then
					callback = endCallback
				end
				M.freezeCell(tile, delay, callback)
				delay = delay + 1
			end
		end
	end
end

M.dumpBoard = function(glyph)
	pprint(board.values)
end

return M