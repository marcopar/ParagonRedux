local M = {}

local CO = require "main.constants"
local BO = require "main.board"
local GL = require "main.glyphs"
local PL = require "main.players"

local currentPlayer = CO.PLAYER1
local swapEvery = 20
local lastSwapAt = 0
local marathon = false

M.newGlyph = function(player)
	PL.setGlyph(player, GL.getRandomGlyph())
end

M.newMatch = function()
	M.resetState()
	M.deleteGame()
	M.newGlyph(CO.PLAYER1)
	M.newGlyph(CO.PLAYER2)
end

M.getNextPlayer = function()
	if(currentPlayer == CO.PLAYER1) then
		return CO.PLAYER2
	else
		return CO.PLAYER1
	end
end

M.getCurrentPlayer = function()
	return currentPlayer
end

M.setCurrentPlayer = function(player)
	currentPlayer = player
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

M.getState = function()
	local state = {currentPlayer={},lastSwapAt={},swapEvery={},marathon={},
		board={},player1glyph={},player2glyph={}}
	state.currentPlayer = currentPlayer
	state.lastSwapAt = lastSwapAt
	state.swapEvery = swapEvery
	state.marathon = marathon
	state.player1glyph = PL.getGlyph(CO.PLAYER1)
	state.player2glyph = PL.getGlyph(CO.PLAYER2)
	state.board = BO.getBoardValues()
	return state
end

M.setState = function(state)
	currentPlayer = state.currentPlayer
	lastSwapAt = state.lastSwapAt
	swapEvery = state.swapEvery
	marathon = state.marathon
	PL.setGlyph(CO.PLAYER1, state.player1glyph)
	PL.setGlyph(CO.PLAYER2, state.player2glyph)
	BO.setBoardValues(state.board)
end

M.resetState = function()
	currentPlayer = CO.PLAYER1
	swapEvery = 20
	lastSwapAt = 0
	marathon = false
	BO.clearBoard()
	PL.clearGlyph(CO.PLAYER1)
	PL.clearGlyph(CO.PLAYER2)
end

M.saveGame = function()
	local filename = sys.get_save_file("paragonredux", "game")
	local state = M.getState()
	sys.save(filename, state)
end

M.deleteGame = function()
	local filename = sys.get_save_file("paragonredux", "game")
	local state = {}
	sys.save(filename, state)
end

M.loadGame = function()
	local filename = sys.get_save_file("paragonredux", "game")
	local state = sys.load(filename)
	if(state.currentPlayer ~= nil) then
		M.setState(state)
		return true
	end
	return false
end

M.isSaveGameExists = function()
	local filename = sys.get_save_file("paragonredux", "game")
	local state = sys.load(filename)
	if(state.currentPlayer ~= nil) then
		return true
	end
	return false
end

return M
	