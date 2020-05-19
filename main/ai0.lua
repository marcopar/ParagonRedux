local M = {}

local CO = require "main.constants"
local BO = require "main.board"
local UT = require "main.utils"

-- dumb AI, places an orb in the first empty cell
function M.think(player, boardValues)


	
	local tile = vmath.vector3()
	for x = CO.BOARD_XMIN, CO.BOARD_XMAX do
		for y = CO.BOARD_YMIN, CO.BOARD_YMAX do
			tile.x = x;
			tile.y = y;
			local cellPos = BO.getCellIndexInBoard(tile)
			local value = boardValues[cellPos]
			if(value == nil) then
				return tile
			end
		end
	end
	return nil
end

return M
	