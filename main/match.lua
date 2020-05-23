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

function M.newGlyph(player)
	PL.setGlyph(player, GL.getRandomGlyph())
end

function M.newMatch()
	M.resetState()
	M.deleteGame()
	M.newGlyph(CO.PLAYER1)
	M.newGlyph(CO.PLAYER2)
end

function M.getNextPlayer()
	if(currentPlayer == CO.PLAYER1) then
		return CO.PLAYER2
	else
		return CO.PLAYER1
	end
end

function M.getCurrentPlayer()
	return currentPlayer
end

function M.setCurrentPlayer(player)
	currentPlayer = player
end

function M.getBoard()
	return BO
end

function M.getPlayers()
	return PL
end

function M.isSwapTriggered()
	local orbCount = BO.getOrbCount().total
	return (swapEvery > 0 and lastSwapAt ~= orbCount and orbCount % swapEvery == 0)
end

function M.isMarathon()
	return marathon
end

function M.setMarathon(value)
	marathon = value
end

function M.setSwapEvery(value)
	swapEvery = value
end

function M.getSwapEvery()
	return swapEvery
end

function M.getState()
	local state = {
		swapEvery=nil, marathon=nil, 
		currentPlayer=nil, lastSwapAt=nil,
		board=nil, player1Glyph=nil, player2Glyph=nil,
		player1Type=nil, player2Type=nil, 
		player1Points=0, player2Points=0
	}
	state.swapEvery = swapEvery
	state.marathon = marathon
	state.currentPlayer = currentPlayer
	state.lastSwapAt = lastSwapAt
	state.player1Type = PL.getType(CO.PLAYER1)
	state.player2Type = PL.getType(CO.PLAYER2)
	state.player1Glyph = PL.getGlyph(CO.PLAYER1)
	state.player2Glyph = PL.getGlyph(CO.PLAYER2)
	state.player1Points = PL.getPoints(CO.PLAYER1)
	state.player2Points = PL.getPoints(CO.PLAYER2)
	state.board = BO.getBoardValues()
	return state
end

function M.setState(state)
	if(state.swapEvery ~= nil) then
		swapEvery = state.swapEvery
	end
	if(state.marathon ~= nil) then
		marathon = state.marathon
	end
	if(state.currentPlayer ~= nil) then
		currentPlayer = state.currentPlayer
	end
	if(state.lastSwapAt ~= nil) then
		lastSwapAt = state.lastSwapAt
	end
	if(state.player1Type ~= nil) then
		PL.setType(CO.PLAYER1, state.player1Type)
	end
	if(state.player2Type ~= nil) then
		PL.setType(CO.PLAYER2, state.player2Type)
	end
	if(state.player1Points ~= nil) then
		PL.setPoints(CO.PLAYER1, state.player1Points)
	end
	if(state.player2Points ~= nil) then
		PL.setPoints(CO.PLAYER2, state.player2Points)
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

function M.resetState()
	currentPlayer = CO.PLAYER1
	lastSwapAt = 0
	BO.clearBoard()
	PL.clearGlyph(CO.PLAYER1)
	PL.clearGlyph(CO.PLAYER2)
	PL.setPoints(CO.PLAYER1, 0)
	PL.setPoints(CO.PLAYER2, 0)
end

function M.getSettings()
	local settings = {
	}
	return settings
end

function M.setSettings(settings)

end

function M.resetSettings()
	UT.log("reset settings")
end

function M.saveGame()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_GAME)
	local state = M.getState()
	local settings = M.getSettings()
	local file = {state = nil, settings = nil}
	file.state = state
	file.settings = settings
	UT.log("saveGame")
	--pprint(file)
	sys.save(filename, file)
end

function M.deleteGame()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_GAME)
	local file = {}
	UT.log("deleteGame")
	--pprint(file)
	sys.save(filename, file)
end

function M.loadGame()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_GAME)
	local file = sys.load(filename)
	if(file.state ~= nil and file.settings ~= nil) then
		M.setState(file.state)
		M.setSettings(file.settings)
		UT.log("loadGame")
		--pprint(file)
		return true
	end
	return false
end

function M.isSaveGameExists()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_GAME)
	local file = sys.load(filename)
	if(file.state ~= nil and file.settings ~= nil) then
		return true
	end
	return false
end

function M.saveSettings()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_SETTINGS)
	local settings = M.getSettings()
	local file = {settings=nil}
	file.settings = settings
	UT.log("saveSettings")
	--pprint(file)
	sys.save(filename, file)
end

function M.deleteSettings()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_SETTINGS)
	local file = {}
	UT.log("deleteSettings")
	--pprint(file)
	sys.save(filename, file)
end

function M.loadSettings()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_SETTINGS)
	local file = sys.load(filename)
	if(file.settings ~= nil) then
		UT.log("loadSettings")
		--pprint(file)
		M.setSettings(file.settings)
		return true
	end
	return false
end

function M.isSettingsExists()
	local filename = sys.get_save_file(CO.FILE_GAMENAME, CO.FILE_SETTINGS)
	local file = sys.load(filename)
	if(file.settings ~= nil) then
		return true
	end
	return false
end

return M
	