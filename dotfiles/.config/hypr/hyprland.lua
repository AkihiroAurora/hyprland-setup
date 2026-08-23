-- Main Hyprland configuration file
-- This sources all the split config files

-- Core configuration
require("configs/00-main")

-- Input devices
require("configs/10-input")

-- Key bindings
require("configs/20-binds")

-- Window rules
require("configs/30-windowrules")

-- Animations and effects
require("configs/40-animations")

-- Startup applications
require("configs/50-startup")
