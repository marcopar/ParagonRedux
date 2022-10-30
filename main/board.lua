local M = {}

local CO = require "main.constants"
local UT = require "main.utils"
local ST = require "main.storage"
local PL = require "main.players"

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

function M.getEmptyCells()
	local emptyCells= {}
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX do
		for y = CO.BOARD_YMIN, CO.BOARD_YMAX do
			local tile = vmath.vector3()
			tile.x = x;
			tile.y = y;
			local cellPos = M.getCellIndexInBoard(tile)
			local value = board.values[cellPos]
			if(value == nil) then
				table.insert(emptyCells, tile)
			end
		end
	end
	return emptyCells
end

function M.scanBoardAtCell(origin, player, glyph)
	local empty = 0
	local matching = 0
	local potentialMatching = 0
	for x = 1, CO.GLYPH_W do
		for y = 1, CO.GLYPH_H do
			local tx = origin.x + (x - 1)
			local ty = origin.y - (y - 1)
			local glyphValue = glyph[x + (y - 1) * CO.GLYPH_H]
			local cellPos = M.getCellIndexInBoard(vmath.vector3(tx, ty, 0))
			local boardValue = board.values[cellPos]
			if(boardValue == nil) then
				empty = empty + 1
			end
			if(glyphValue == 1 and (boardValue == player or boardValue == nil)) then
				if(boardValue == nil) then
					potentialMatching = potentialMatching + 1
				else
					matching = matching + 1
				end	
			end
		end
	end
	local scanResult = {empty=true, matching=0, canComplete=false}
	scanResult.matching = matching
	scanResult.empty = empty == (CO.GLYPH_W * CO.GLYPH_H)
	scanResult.canComplete = (matching + potentialMatching == CO.GLYPH_ORBS)
	return scanResult
end

function M.scanBoard(player, glyph)
	local scanResult = {empty={}, blocked={}, matching1={}, matching2={}, matching3={}, matching4={}, emptyCells={}}
	-- explore from top left and match from top left as glyphs have the origin in top left
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX - 2 do
		for y = CO.BOARD_YMAX, CO.BOARD_YMIN + 2, -1 do
			local tile = vmath.vector3()
			tile.x = x;
			tile.y = y;
			local scanResultTile = M.scanBoardAtCell(tile, player, glyph)
			if scanResultTile.empty then
				table.insert(scanResult.empty, tile)
			elseif not scanResultTile.canComplete then
				table.insert(scanResult.blocked, tile)
			elseif scanResultTile.matching == 1 then
				table.insert(scanResult.matching1, tile)
			elseif scanResultTile.matching == 2 then
				table.insert(scanResult.matching2, tile)
			elseif scanResultTile.matching == 3 then
				table.insert(scanResult.matching3, tile)
			elseif scanResultTile.matching == 4 then
				table.insert(scanResult.matching4, tile)
			end
		end
	end

	scanResult.emptyCells = M.getEmptyCells()
	--if(player == CO.PLAYER1) then
	--	UT.log("scan board " .. player)
	--	pprint(scanResult)
	--end
	return scanResult
end

function M.setCell(tile, player)
	UT.log("set cell player=" .. player)
	local color
	if(player == CO.FREEZED) then
		color = CO.FREEZED_ORB
	else
		color = PL.getColor(player)
	end
	local orb = UT.createOrb(tile, color, 0.5)
	local cellPos = M.getCellIndexInBoard(tile)
	board.sprites[cellPos] = orb
	board.values[cellPos] = player
end

function M.freezeCell(tile, delay, callback)
	local cellPos = M.getCellIndexInBoard(tile)
	local orb = board.sprites[cellPos]
	UT.changeOrbType(orb, CO.FREEZED_ORB, delay, callback)
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
				UT.changeOrbType(orb, PL.getColor(newValue), 0, callback)
				board.values[cellPos] = newValue
			end
		end
	end
	msg.post("controller:/controller", CO.SOUND_SWAP)
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
function M.checkMatchingGlyph(player, glyph, checkPotentialMatch)
	local tile = vmath.vector3()
	-- explore from top left and match from top left as glyphs have the origin in top left
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX - 2 do
		for y = CO.BOARD_YMAX, CO.BOARD_YMIN + 2, -1 do
			tile.x = x;
			tile.y = y;
			local scanResult = M.scanBoardAtCell(tile, player, glyph)
			if(checkPotentialMatch and scanResult.canComplete) then
				return tile
			end
			if(scanResult.matching == CO.GLYPH_ORBS) then
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

function M.setCurrentPlayerOrb(player)
	sprite.play_flipbook("game:/currentPlayerOrb", CO.ORBS[PL.getColor(player)])
	sprite.play_flipbook("game:/currentPlayerHalo", CO.ORBS[PL.getColor(player)])
end

return M