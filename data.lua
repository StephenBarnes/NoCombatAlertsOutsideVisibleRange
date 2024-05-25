-- We take the base game's icons for destroyed/damaged buildings, and then create virtual signals for those icons.
-- This is necessary because custom alerts can only use virtual signals for their icons.
data:extend({
	{
		type = "virtual-signal",
		name = "NCAOVR-destroyed-icon",
		icon = "__core__/graphics/icons/alerts/destroyed-icon.png",
		icon_size = 64,
	},
	{
		type = "virtual-signal",
		name = "NCAOVR-danger-icon",
		icon = "__core__/graphics/icons/alerts/danger-icon.png",
		icon_size = 64,
	},
})
