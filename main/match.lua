local M = {}

local C = require "main.constants"
local B = require "main.board"
local G = require "main.glyphs"
local P = require "main.players"

local currentPlayer = C.PLAYER2
local swapEvery = 20
local lastSwapAt = 0


M.newGlyph = function(player)
	P.setGlyph(player, G.getRandomGlyph())
end

M.newMatch = function()
	B.clearBoard()
	M.newGlyph(C.PLAYER1)
	M.newGlyph(C.PLAYER2)
end

M.getNextPlayer = function()
	if(currentPlayer == C.PLAYER1) then
		currentPlayer =  C.PLAYER2
	else
		currentPlayer =  C.PLAYER1
	end
	return currentPlayer
end

M.getBoard = function()
	return B
end

M.getPlayers = function()
	return P
end

M.isSwapTriggered = function()
	local orbCount = B.getOrbCount().total
	return (swapEvery > 0 and lastSwapAt ~= orbCount and orbCount % swapEvery == 0)
end



return M