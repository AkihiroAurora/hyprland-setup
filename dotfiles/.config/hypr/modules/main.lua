hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.env("XCURSOR_THEME", "BreezeX-Black")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
	general = {
		border_size = 2,
		gaps_in = 5,
		gaps_out = 15,
		layout = "dwindle",
		col = {
			active_border = "rgba(cba6f7ff)",
			inactive_border = "rgba(595959aa)",
		},
	},

	decoration = {
		rounding = 3,
		blur = {
			enabled = true,
		},

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
	},

	dwindle = {
		preserve_split = true,
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})
