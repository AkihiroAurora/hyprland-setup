-- Assign apps to specific workspaces
hl.window_rule({
	match = { class = "zen" },
	workspace = "1",
})

hl.window_rule({
	match = { class = "vesktop" },
	workspace = "2",
})

-- Rofi layer rule
hl.layer_rule({
	match = { class = "rofi" },
	animation = "popin 60%",
})
