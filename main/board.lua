local M = {}

local CO = require "main.constants"
local UT = require "main.utils"
local ST = require "main.storage"

local board = {sprites={}, values={}}

function M.getCellIndexInBoard(tile)
	return (tile.x + math.abs(CO.BOARD_XMIN)) + (tile.y + math.abs(CO.BOARD_YMIN)) * CO.BOARD_H
end

function M.getTileFromCellIndex(idx)
	local tile = vmath.vector3()
	tile.x = idx % CO.BOARD_H - math.abs(CO.BOARD_XMIN)
	tile.y = math.floor(idx / CO.BOARD_H) - math.abs(CO.BOARD_YMIN)
	return tile
end

function M.isOnBoard(tile) 
	if(tile.x >= CO.BOARD_XMIN and tile.x <= CO.BOARD_XMAX and tile.y >= CO.BOARD_YMIN and tile.y <=CO.BOARD_YMAX) then
		return true
	end
	return false
end

function M.setCell(tile, player)
	local orb = UT.createOrb(tile, player, 0.5)
	local cellPos = M.getCellIndexInBoard(tile)
	board.sprites[cellPos] = orb
	board.values[cellPos] = player
end

function M.freezeCell(tile, delay, callback)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	UT.changeOrbType(orb, CO.FREEZED, delay, callback)
	board.values[cellPos] = CO.FREEZED	
end

function M.clearCell(tile)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	UT.deleteOrb(orb)
	board.sprites[cellPos] = nil
	board.values[cellPos] = nil
end

function M.clearCellAnimated(tile, delay, callback)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	UT.deleteOrbAnimated(orb, delay, callback)
	board.sprites[cellPos] = nil
	board.values[cellPos] = nil
end

function M.swapCell(tile, callback)
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

function M.getCell(tile)
	local cellPos = M.getCellIndexInBoard(tile)
	return board.values[cellPos]
end

function M.swapBoard(endCallback)
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

function M.clearBoard()
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

function M.getOrbCount()
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

-- checkPotentialMatch treats empty slots as slots occupied by player
-- used to check if player can still make a match
function M.checkMatchingGlyphAtTile(origin, player, glyph, checkPotentialMatch)
	local matching = 0
	for x = 1, CO.GLYPH_W do
		for y = 1, CO.GLYPH_H do
			local tx = origin.x + (x - 1)
			local ty = origin.y - (y - 1)
			local glyphValue = glyph[x + (y - 1) * CO.GLYPH_H]
			local cellPos = M.getCellIndexInBoard(vmath.vector3(tx, ty, 0))
			local boardValue = board.values[cellPos]
			if(checkPotentialMatch and boardValue == nil) then
				-- empty slot, simulate it's occupied by player
				boardValue = player
			end
			if(glyphValue == 1 and boardValue == player) then
				matching = matching + 1
			end
		end
	end
	return (matching == CO.GLYPH_ORBS)
end

-- checkPotentialMatch treats empty slots as slots occupied by player
-- used to check if player can still make a match
function M.checkMatchingGlyph(player, glyph, checkPotentialMatch)
	local tile = vmath.vector3()
	-- explore from top left and match from top left as glyphs have the origin in top left
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX - 2 do
		for y = CO.BOARD_YMAX, CO.BOARD_YMIN + 2, -1 do
			tile.x = x;
			tile.y = y;
			if(M.checkMatchingGlyphAtTile(tile, player, glyph, checkPotentialMatch)) then
				return tile
			end
		end
	end		
	return nil
end

function M.setGlyphCompleted(origin, glyph, marathon, endCallback)
	local delay = 1
	for x = 1, CO.GLYPH_W do
		for y = 1, CO.GLYPH_H do
			local tx = origin.x + (x - 1)
			local ty = origin.y - (y - 1)
			local i = x + (y - 1) * CO.GLYPH_H
			if(glyph[i] == 1) then
				local tile = vmath.vector3(tx, ty, 0)
				local callback = nil
				-- add callback only for the last freezed
				if(delay == CO.GLYPH_ORBS) then
					callback = endCallback
				end
				if(marathon) then
					M.clearCellAnimated(tile, delay, callback)
				else
					M.freezeCell(tile, delay, callback)
				end
				delay = delay + 1
			end
		end
	end
end

function M.getBoardValues()
	local copy = {}
	for k,v in pairs(board.values) do
		copy[k] = v
	end
	return copy
end

function M.setBoardValues(values)
	M.clearBoard()
	local tile = vmath.vector3()
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX do
		for y = CO.BOARD_YMIN, CO.BOARD_YMAX do
			tile.x = x;
			tile.y = y;
			local cellPos = M.getCellIndexInBoard(tile)
			if(values[cellPos] ~= nil) then
				M.setCell(tile, values[cellPos])
			end
		end
	end
end

return M