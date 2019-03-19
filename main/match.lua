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
	local state = {currentPlayer={},lastSwapAt={},
		board={},player1glyph={},player2glyph={}}
	state.currentPlayer = currentPlayer
	state.lastSwapAt = lastSwapAt
	state.player1glyph = PL.getGlyph(CO.PLAYER1)
	state.player2glyph = PL.getGlyph(CO.PLAYER2)
	state.board = BO.getBoardValues()
	return state
end

M.setState = function(state)
	currentPlayer = state.currentPlayer
	lastSwapAt = state.lastSwapAt
	PL.setGlyph(CO.PLAYER1, state.player1glyph)
	PL.setGlyph(CO.PLAYER2, state.player2glyph)
	BO.setBoardValues(state.board)
end

M.resetState = function()
	currentPlayer = CO.PLAYER1
	swapEvery = 20
	BO.clearBoard()
	PL.clearGlyph(CO.PLAYER1)
	PL.clearGlyph(CO.PLAYER2)
end

M.getSettings = function()
	local settings = {swapEvery={},marathon={}}
	settings.swapEvery = swapEvery
	settings.marathon = marathon
	return settings
end

M.setSettings = function(settings)
	swapEvery = settings.swapEvery
	marathon = settings.marathon
end

M.resetSettings = function()
	lastSwapAt = 0
	marathon = false
end

M.saveGame = function()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_GAME)
	local state = M.getState()
	local settings = M.getSettings()
	local file = {state = {}, settings = {}}
	file.state = state
	file.settings = settings
	sys.save(filename, file)
end

M.deleteGame = function()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_GAME)
	local file = {}
	sys.save(filename, file)
end

M.loadGame = function()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_GAME)
	local file = sys.load(filename)
	if(file.state ~= nil and file.settings ~= nil) then
		M.setState(file.state)
		M.setSettings(file.settings)
		return true
	end
	return false
end

M.isSaveGameExists = function()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_GAME)
	local file = sys.load(filename)
	if(file.state ~= nil and file.settings ~= nil) then
		return true
	end
	return false
end

M.saveSettings = function()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_SETTINGS)
	local settings = M.getSettings()
	local file = {settings={}}
	file.settings = settings
	sys.save(filename, file)
end

M.deleteSettings = function()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_SETTINGS)
	local file = {}
	sys.save(filename, file)
end

M.loadSettings = function()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_SETTINGS)
	local file = sys.load(filename)
	if(file.settings ~= nil) then
		M.setSettings(file.settings)
		return true
	end
	return false
end

M.isSettingsExists = function()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_SETTINGS)
	local file = sys.load(filename)
	if(file.settings ~= nil) then
		return true
	end
	return false
end

return M
	