local M = {}

local CO = require "main.constants"
local BO = require "main.board"
local UT = require "main.utils"
local MA = require "main.match"

function M.think(player)
	local playerGlyph = MA.getPlayers().getGlyph(player)
	local playerScanResult = BO.scanBoard(player, playerGlyph)
	local oppenentPlayer = MA.getOpponentPlayer(player)
	local opponentPlayerGlyph = MA.getPlayers().getGlyph(oppenentPlayer)
	local opponentPlayerScanResult = BO.scanBoard(oppenentPlayer, opponentPlayerGlyph)

	local emptyTiles = playerScanResult.emptyTiles
	if(#emptyTiles ~= 0) then
		return emptyTiles[math.random(#emptyTiles)]
	end
	return nil
end

return M