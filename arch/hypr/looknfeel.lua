-- Personal look'n'feel overrides. Loaded after Omarchy defaults via
-- require("hypr.looknfeel").

hl.config({
	general = {
		-- No gaps between windows or borders.
		gaps_in = 0,
		gaps_out = 0,
		border_size = 0,
	},
	dwindle = {
		preserve_split = true,
		force_split = 0,
	},
	decoration = {
		-- Rounded window corners.
		rounding = 0,
	},
})
