local M = {}

-- player1, player2, freezed as defined by the following constants
M.ORBS = {hash("red_orb"), hash("blue_orb"), hash("white_orb")}
M.PLAYER1 = 1
M.PLAYER2 = 2
M.FREEZED = 3

M.TILE_W = 72
M.TILE_H = 72

M.BOARD_W = 14
M.BOARD_H = 14
M.BOARD_XMIN = -6
M.BOARD_XMAX = 7
M.BOARD_YMIN = -11
M.BOARD_YMAX = 2

M.PLAYER1_GRID_XMIN = -6
M.PLAYER1_GRID_XMAX = -4
M.PLAYER1_GRID_YMIN = 5
M.PLAYER1_GRID_YMAX = 7

M.PLAYER2_GRID_XMIN = 5
M.PLAYER2_GRID_XMAX = 7
M.PLAYER2_GRID_YMIN = 5
M.PLAYER2_GRID_YMAX = 7

M.GLYPH_W = 3
M.GLYPH_H = 3
M.GLYPH_ORBS = 5

M.SCREEN_GAME = "GAME"
M.SCREEN_SETTINGS = "SETTINGS"
M.SCREEN_ABOUT = "ABOUT"
M.SCREEN_MAINMENU = "MAINMENU"
M.SCREEN_NEWRESUME = "NEWRESUME"
M.SCREEN_INFORMATION_POPUP = "INFORMATION_POPUP"
M.SCREEN_CONFIRMATION_POPUP = "CONFIRMATION_POPUP"

M.GUI_PLAY = "play"
M.GUI_NEWGAME = "newgame"
M.GUI_RESUMEGAME = "resumegame"
M.GUI_SETTINGS = "settings"
M.GUI_ABOUT = "about"
M.GUI_BACK = "back"
M.GUI_SWAPEVERY = "swapevery"
M.GUI_MARATHON = "marathon"
M.GUI_MAINMENU = "mainmenu"
M.GUI_PLAYER1TYPE = "player1"
M.GUI_PLAYER2TYPE = "player2"
M.GUI_TEXT = "text"
M.GUI_OK = "ok"
M.GUI_CANCEL = "cancel"
M.GUI_WINDOW = "window"
M.GUI_OKBUTTON = "okbutton"
M.GUI_CANCELBUTTON = "cancelbutton"

M.MESSAGE_NEWGAME = "NEWGAME"
M.MESSAGE_RESUMEGAME = "RESUMEGAME"
M.MESSAGE_LOADSETTINGS = "LOADSETTINGS"
M.MESSAGE_TRIGGERAI = "TRIGGERAI"

M.FILE_GAMENAME = "paragonredux"
M.FILE_SETTINGS = "settings"
M.FILE_GAME = "game"

M.SETTINGS_PLAYER_TYPE_HUMAN = "HUMAN"
M.SETTINGS_PLAYER_TYPE_AI1 = "AI1"
M.SETTINGS_PLAYER_TYPE_AI2 = "AI2"
M.SETTINGS_PLAYER_TYPE_AI3 = "AI3"
M.SETTINGS_PLAYER_TYPES = { M.SETTINGS_PLAYER_TYPE_HUMAN, M.SETTINGS_PLAYER_TYPE_AI1,M.SETTINGS_PLAYER_TYPE_AI2, M.SETTINGS_PLAYER_TYPE_AI3 }

return M