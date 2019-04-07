local M = {}

local CO = require "main.constants"
local BO = require "main.board"
local GL = require "main.glyphs"
local PL = require "main.players"
local UT = require "main.utils"

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

M.getPlayers= function()
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
	local state = {currentPlayer=nil,lastSwapAt=nil,
	board=nil,player1Glyph=nil,player2Glyph=nil,
	player1Type=nil, player2Type=nil}
	state.currentPlayer = currentPlayer
	state.lastSwapAt = lastSwapAt
	state.player1Type = player1Type
	state.player2Type = player2Type
	state.player1Glyph = PL.getGlyph(CO.PLAYER1)
	state.player2Glyph = PL.getGlyph(CO.PLAYER2)
	state.board = BO.getBoardValues()
	return state
end

M.setState = function(state)
	if(state.currentPlayer ~= nil) then
		currentPlayer = state.currentPlayer
	end
	if(state.lastSwapAt ~= nil) then
		lastSwapAt = state.lastSwapAt
	end
	if(state.player1Type ~= nil) then
		player1Type = state.player1Type
	end
	if(state.player2Type ~= nil) then
		player2Type = state.player2Type
	end
	if(state.player1Glyph ~= nil) then
		PL.setGlyph(CO.PLAYER1, state.player1Glyph)
	end
	if(state.player2Glyph ~= nil) then
		PL.setGlyph(CO.PLAYER2, state.player2Glyph)
	end
	if(state.board ~= nil) then
		BO.setBoardValues(state.board)
	end
end

M.resetState = function()
	currentPlayer = CO.PLAYER1
	swapEvery = 20
	player1Type = CO.SETTINGS_PLAYER_TYPE_HUMAN
	player2Type = CO.SETTINGS_PLAYER_TYPE_HUMAN
	BO.clearBoard()
	PL.clearGlyph(CO.PLAYER1)
	PL.clearGlyph(CO.PLAYER2)
end

M.getSettings = function()
	local settings = {swapEvery=nil,marathon=nil, player1Type=nil, player2Type=nil}
	settings.swapEvery = swapEvery
	settings.marathon = marathon
	settings.player1Type = PL.getType(CO.PLAYER1)
	settings.player2Type = PL.getType(CO.PLAYER2)
	return settings
end

M.setSettings = function(settings)
	if(settings.currentPlayer ~= nil) then
		currentPlayer = settings.currentPlayer
	end
	if(settings.lastSwapAt ~= nil) then
		lastSwapAt = settings.lastSwapAt
	end
	if(settings.player1Type ~= nil) then
		PL.setType(CO.PLAYER1, settings.player1Type)
	end
	if(settings.player2Type ~= nil) then
		PL.setType(CO.PLAYER2, settings.player2Type)
	end
end

M.resetSettings = function()
	lastSwapAt = 0
	marathon = false
	PL.setType(CO.PLAYER1, CO.SETTINGS_PLAYER_TYPE_HUMAN)
	PL.setType(CO.PLAYER2, CO.SETTINGS_PLAYER_TYPE_HUMAN)
end

M.saveGame = function()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_GAME)
	local state = M.getState()
	local settings = M.getSettings()
	local file = {state = nil, settings = nil}
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
	local file = {settings=nil}
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
	