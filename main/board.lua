local M = {}

local CO = require "main.constants"
local UT = require "main.utils"
local ST = require "main.storage"

local board = {sprites={}, values={}}

M.getCellIndexInBoard = function(tile)
	-- tile x, y can be negative as the tilemap is centered in the world origin, so the offset in the array can also be negative (not an issue in lua 8-))
	return tile.x + tile.y * CO.BOARD_H
end

M.isOnBoard =  function(tile) 
	if(tile.x >= CO.BOARD_XMIN and tile.x <= CO.BOARD_XMAX and tile.y >= CO.BOARD_YMIN and tile.y <=CO.BOARD_YMAX) then
		return true
	end
	return false		
end

M.setCell = function(tile, player)
	local orb = UT.createOrb(tile, player, 0.5)
	local cellPos = M.getCellIndexInBoard(tile)
	board.sprites[cellPos] = orb
	board.values[cellPos] = player
end

M.freezeCell = function(tile, delay, callback)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	UT.changeOrbType(orb, CO.FREEZED, delay, callback)
	board.values[cellPos] = CO.FREEZED	
end

M.swapCell = function(tile, callback)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	local value = board.values[cellPos]
	if(value == CO.PLAYER1) then
		UT.changeOrbType(orb, CO.PLAYER2, 0, callback)
		board.values[cellPos] = CO.PLAYER2
	elseif(value == CO.PLAYER2) then
		UT.changeOrbType(orb, CO.PLAYER1, 0, callback)
		board.values[cellPos] = CO.PLAYER1
	end
end

M.clearCell = function(tile)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	UT.deleteOrb(orb)
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
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX do
		for y = CO.BOARD_YMIN, CO.BOARD_YMAX do
			tile.x = x;
			tile.y = y;
			local cellPos = M.getCellIndexInBoard(tile)
			local orb = board.sprites[cellPos]
			local value = board.values[cellPos]
			local newValue = nil
			if(value == CO.PLAYER1) then
				newValue = CO.PLAYER2
				swapped = swapped + 1
			elseif(value == CO.PLAYER2) then
				newValue = CO.PLAYER1
				swapped = swapped + 1
			end
			local callback = nil
			if(swapped == (counters.p1 + counters.p2)) then
				callback = endCallback
			end
			if(newValue ~= nil) then
				UT.changeOrbType(orb, newValue, 0, callback)
				board.values[cellPos] = newValue
			end
		end
	end
end

M.clearBoard = function()
	local tile = vmath.vector3()
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX do
		for y = CO.BOARD_YMIN, CO.BOARD_YMAX do
			tile.x = x;
			tile.y = y;
			M.clearCell(tile)
		end
	end
	ST.clear()
end

M.getOrbCount = function()
	local tile = vmath.vector3()
	local totalCount = 0
	local p1Count = 0
	local p2Count = 0
	local freezedCount = 0
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX do
		for y = CO.BOARD_YMIN, CO.BOARD_YMAX do
			tile.x = x;
			tile.y = y;
			local cell = M.getCell(tile)
			if(cell ~= nil) then
				if(cell == CO.PLAYER1) then
					p1Count = p1Count + 1
				elseif(cell == CO.PLAYER2) then
					p2Count = p2Count + 1
				elseif(cell == CO.FREEZED) then
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
	for x = 1, CO.GLYPH_W do
		for y = 1, CO.GLYPH_H do
			local tx = origin.x + (x - 1)
			local ty = origin.y - (y - 1)
			if(glyph[x + (y - 1) * CO.GLYPH_H] == 1 and board.values[tx + ty * CO.BOARD_H] == player) then
				matching = matching + 1
			end
		end
	end
	return (matching == CO.GLYPH_ORBS)
end

M.checkMatchingGlyph = function(player, glyph)
	local tile = vmath.vector3()
	-- TODO maybe the original explores the board following the rows instead of columns
	-- explore from top left and match from top left as glyphs have the origin in top left
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX - 2 do
		for y = CO.BOARD_YMAX, CO.BOARD_YMIN + 2, -1 do
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
	local delay = 1
	for x = 1, CO.GLYPH_W do
		for y = 1, CO.GLYPH_H do
			local tx = origin.x + (x - 1)
			local ty = origin.y - (y - 1)
			local i = x + (y - 1) * CO.GLYPH_H
			if(glyph[i] == 1) then
				local tile = vmath.vector3(tx, ty, 0)
				local callback = nil
				if(delay == (CO.GLYPH_ORBS - 1)) then
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