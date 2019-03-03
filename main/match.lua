local M = {}

local CO = require "main.constants"
local BO = require "main.board"
local GL = require "main.glyphs"
local PL = require "main.players"

local currentPlayer = CO.PLAYER2
local swapEvery = 20
local lastSwapAt = 0
local marathon = false


M.newGlyph = function(player)
	PL.setGlyph(player, GL.getRandomGlyph())
end

M.newMatch = function()
	BO.clearBoard()
	M.newGlyph(CO.PLAYER1)
	M.newGlyph(CO.PLAYER2)
	currentPlayer = CO.PLAYER2
end

M.getNextPlayer = function()
	if(currentPlayer == CO.PLAYER1) then
		currentPlayer =  CO.PLAYER2
	else
		currentPlayer =  CO.PLAYER1
	end
	return currentPlayer
end

M.getBoard = function()
	return BO
end

M.getPlayers = function()
	return PL
end

M.isSwapTriggered = function()
	local orbCount = BO.getOrbCount().total
	return (swapEvery > 0 and lastSwapAt ~= orbCount and orbCount % swapEvery == 0)
end

M.isMarathon = function()
	return marathon
end

M.setMarathon = function(value)
	marathon = value
end

M.setSwapEvery = function(value)
	swapEvery = value
end

M.getSwapEvery = function()
	return swapEvery
end

return M