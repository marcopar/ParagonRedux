local M = {}

local CO = require "main.constants"
local BO = require "main.board"
local UT = require "main.utils"
local MA = require "main.match"

local function getAIParameters(playerType)
	local parameters = {smartness = 0, aggressiveness=0}
	if(playerType == CO.SETTINGS_PLAYER_TYPE_AI1) then
		parameters.smartness = 20
		parameters.aggressiveness = 20
	elseif (playerType == CO.SETTINGS_PLAYER_TYPE_AI2) then
		parameters.smartness = 40
		parameters.aggressiveness = 20
	elseif (playerType == CO.SETTINGS_PLAYER_TYPE_AI3) then
		parameters.smartness = 60
		parameters.aggressiveness = 40
	elseif (playerType == CO.SETTINGS_PLAYER_TYPE_AI4) then
		parameters.smartness = 80
		parameters.aggressiveness = 40
	elseif (playerType == CO.SETTINGS_PLAYER_TYPE_AI5) then
		parameters.smartness =  80
		parameters.aggressiveness = 60
	end
	return parameters
end

local function getEmptyMatchingCellInTile(origin, glyph)
	local empty = {}
	for x = 1, CO.GLYPH_W do
		for y = 1, CO.GLYPH_H do
			local cell = vmath.vector3()			
			cell.x = origin.x + (x - 1)
			cell.y = origin.y - (y - 1)
			cell.z = 0
			local boardValue = BO.getCell(cell)
			local glyphValue = glyph[x + (y - 1) * CO.GLYPH_H]
			if(boardValue == nil and glyphValue == 1) then
				table.insert(empty, cell)
			end
		end
	end
	return empty[math.random(#empty)]
end

local function selectCell(matchTable, glyph)
	if(#matchTable ~= 0) then
		local tile = matchTable[math.random(#matchTable)]
		return getEmptyMatchingCellInTile(tile, glyph)
	end
end

function M.think(player)
	local playerGlyph = MA.getPlayers().getGlyph(player)
	local playerType = MA.getPlayers().getType(player)
	local playerScanResult = BO.scanBoard(player, playerGlyph)
	local oppenentPlayer = MA.getOpponentPlayer(player)
	local opponentPlayerGlyph = MA.getPlayers().getGlyph(oppenentPlayer)
	local opponentPlayerScanResult = BO.scanBoard(oppenentPlayer, opponentPlayerGlyph)

	local parameters = getAIParameters(playerType)

	if(math.random(100) <= parameters.smartness) then
		-- smart placement
		local selectedCell

		if(math.random(100) <= parameters.aggressiveness) then
			selectedCell = selectCell(playerScanResult.matching4, playerGlyph)
			if(selectedCell ~=  nil) then
				return selectedCell
			end
			selectedCell = selectCell(opponentPlayerScanResult.matching4, opponentPlayerGlyph)
			if(selectedCell ~=  nil) then
				return selectedCell
			end
		else
			selectedCell = selectCell(opponentPlayerScanResult.matching4, opponentPlayerGlyph)
			if(selectedCell ~=  nil) then
				return selectedCell
			end
			selectedCell = selectCell(playerScanResult.matching4, playerGlyph)
			if(selectedCell ~=  nil) then
				return selectedCell
			end
		end

		selectedCell = selectCell(opponentPlayerScanResult.matching3, opponentPlayerGlyph)
		if(selectedCell ~=  nil) then
			return selectedCell
		end
		if(playerType == CO.SETTINGS_PLAYER_TYPE_AI5) then
			selectedCell = selectCell(opponentPlayerScanResult.matching2, opponentPlayerGlyph)
			if(selectedCell ~=  nil) then
				return selectedCell
			end
		end
		selectedCell = selectCell(playerScanResult.matching3, playerGlyph)
		if(selectedCell ~=  nil) then
			return selectedCell
		end
		selectedCell = selectCell(playerScanResult.matching2, playerGlyph)
		if(selectedCell ~=  nil) then
			return selectedCell
		end
		selectedCell = selectCell(playerScanResult.matching1, playerGlyph)
		if(selectedCell ~=  nil) then
			return selectedCell
		end
		selectedCell = selectCell(playerScanResult.empty, playerGlyph)
		if(selectedCell ~=  nil) then
			return selectedCell
		end
	end

	-- dumb placement, random
	local emptyCells = playerScanResult.emptyCells
	if(#emptyCells ~= 0) then
		return emptyCells[math.random(#emptyCells)]
	end
	
	return nil
end

return M