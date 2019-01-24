local M = {}

M.CAMERA_ID = hash("/camera")
-- player1, player2, freezed as defined by the underlying constants
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

return M