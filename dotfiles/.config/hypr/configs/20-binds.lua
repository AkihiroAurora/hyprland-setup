-- Mod keys
local mainMod = "ALT"

-- Application binds
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("~/.config/rofi/scripts/wallpaper-launcher.sh"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + DELETE", hl.dsp.window.kill())
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + M", hl.dsp.exit())

-- Focus movement
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Window movement
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Window resizing
hl.bind("ALT + CTRL + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind("ALT + CTRL + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind("ALT + CTRL + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind("ALT + CTRL + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd("grim -t png -l 5 ~/Pictures/screenshots/screenshot_$(date +%s).png"))
hl.bind(
	"SHIFT + PRINT",
	hl.dsp.exec_cmd(
		'grim -t png -l 0 -g "$(slurp -b 1e1e2e80 -c cba6f7 -w 2 -d)" ~/Pictures/screenshots/screenshot_$(date +%s).png'
	)
)
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("CTRL + SHIFT + PRINT", hl.dsp.exec_cmd('grim -g "$(slurp -b 1e1e2e80 -c cba6f7 -w 2 -d)" - | wl-copy'))

-- Mouse binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
