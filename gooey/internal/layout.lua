--- Module to layout and arrange nodes

local M = {}


local function get_node(node)
	return type(node) == "string" and gui.get_node(node) or node
end


local function calculate_total_height(nodes, spacing)
	local height = 0
	for _,node in pairs(nodes) do
		node = get_node(node)
		if gui.is_enabled(node) then
			local size = gui.get_size(node)
			height = height + size.y
		end
	end
	if #nodes > 1 then
		height = height + ((#nodes - 1) * spacing)
	end
	return height
end

local function get_pivot_center_offset(node)
	assert(node, "You must provide a node")
	node = get_node(node)

	local size = gui.get_size(node)
	local offset = vmath.vector3()
	local pivot = gui.get_pivot(node)
	if pivot == gui.PIVOT_CENTER then
		-- do nothing
	elseif pivot == gui.PIVOT_E then
		offset.x = size.x / 2
	elseif pivot == gui.PIVOT_N then
		offset.y = size.y / 2
	elseif pivot == gui.PIVOT_S then
		offset.y = -size.y / 2
	elseif pivot == gui.PIVOT_NE then
		offset.x = size.x / 2
		offset.y = size.y / 2
	elseif pivot == gui.PIVOT_SE then
		offset.x = size.x / 2
		offset.y = -size.y / 2
	elseif pivot == gui.PIVOT_W then
		offset.x = -size.x / 2
	elseif pivot == gui.PIVOT_NW then
		offset.x = -size.x / 2
		offset.y = size.y / 2
	elseif pivot == gui.PIVOT_SW then
		offset.x = -size.x / 2
		offset.y = -size.y / 2
	end
	return offset
end

--- Arrange zero or more nodes vertically
-- The nodes will be arranged within the slice-9 of the background
-- @param background
-- @param spacing
-- @param margin_top
-- @param margin_bottom
-- @param ... The nodes to arrange
function M.arrange_vertically(background, spacing, margin_top, margin_bottom, ...)
	background = get_node(background)
	local bg_slice9 = gui.get_slice9(background)
	local bg_size = gui.get_size(background)

	local nodes = {...}
	local nodes_height = calculate_total_height(nodes, spacing)

	-- resize background such that it fits all nodes
	bg_size.y = bg_slice9.y + bg_slice9.w + nodes_height
	gui.set_size(background, bg_size)

	-- find top y and arrange from there
	local offset = get_pivot_center_offset(background)
	local y = (bg_size.y / 2) - offset.y - bg_slice9.y - margin_top
	for _,node in ipairs({...}) do
		node = get_node(node)
		if gui.is_enabled(node) then
			local node_position = gui.get_position(node)
			local node_size = gui.get_size(node)
			local pivot = gui.get_pivot(node)
			local node_height = node_size.y
			node_position.y = y
			if pivot == gui.PIVOT_W or pivot == gui.PIVOT_E or pivot == gui.PIVOT_CENTER then
				node_position.y = node_position.y - (node_size.y / 2)
			elseif pivot == gui.PIVOT_S or pivot == gui.PIVOT_SE or pivot == gui.PIVOT_SW then
				node_position.y = node_position.y - node_size.y
			end
			gui.set_position(node, node_position)
			y = y - spacing - node_size.y
		end
	end
end

--- Center a node
-- @param node
-- @param position The position on which to center the node
function M.center(node, position)
	assert(node, "You must provide a node")
	assert(position, "You must provide a position")
	node = get_node(node)
	local offset = get_pivot_center_offset(node)
	gui.set_position(node, position + offset)
end

local function position_child(child, parent, offset, dx, dy)
	assert(child, "You must provide a child node")
	assert(parent, "You must provide a parent node")
	offset = offset or vmath.vector3()
	child = get_node(child)
	parent = get_node(parent)

	local parent_offset = get_pivot_center_offset(parent)
	local parent_size = gui.get_size(parent)
	local child_size = gui.get_size(child)
	gui.set_parent(child, parent)

	local position = vmath.vector3(
			((parent_size.x / 2) - parent_offset.x) * dx,
			((parent_size.y / 2) - parent_offset.y) * dy,
			0)
		- vmath.vector3(
			(child_size.x / 2) * dx,
			(child_size.y / 2) * dy,
			0)
	M.center(child, position + offset)
end

--- Position child in top right corner of a parent node
-- @param node
-- @param parent
-- @param offset Offset from top-right corner
function M.child_top_right(child, parent, offset)
	position_child(child, parent, offset, 1, 1)
end

--- Position child in top left corner of a parent node
-- @param node
-- @param parent
-- @param offset Offset from top-right corner
function M.child_top_left(child, parent, offset)
	position_child(child, parent, offset, -1, 1)
end

--- Position child in top of a parent node
-- @param node
-- @param parent
-- @param offset Offset from top
function M.child_top(child, parent, offset)
	position_child(child, parent, offset, 0, 1)
end

--- Position child at bottom of a parent node
-- @param node
-- @param parent
-- @param offset Offset from bottom
function M.child_bottom(child, parent, offset)
	position_child(child, parent, offset, 0, -1)
end

--- Position child at bottom right corner of a parent node
-- @param node
-- @param parent
-- @param offset Offset from bottom right
function M.child_bottom_right(child, parent, offset)
	position_child(child, parent, offset, 1, -1)
end

--- Position child at bottom left corner of a parent node
-- @param node
-- @param parent
-- @param offset Offset from bottom left
function M.child_bottom_left(child, parent, offset)
	position_child(child, parent, offset, -1, -1)
end



return M
