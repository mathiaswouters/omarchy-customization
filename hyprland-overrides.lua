-- Hyprland configuration overrides
-- Loaded from ~/.config/hypr/hyprland.lua via install-hyprland-overrides.sh,
-- after Omarchy's defaults, so everything here wins.
--
-- API reference:
--   Omarchy helpers (o.*): $OMARCHY_PATH/default/hypr/helpers.lua
--   Hyprland Lua (hl.*):   /usr/share/hypr/stubs/hl.meta.lua
--   Current bindings:      omarchy menu keybindings --print

local terminal = "foot"
local browser = "brave-browser"

-- Directory this file lives in, so the script bindings below work wherever the
-- repo is cloned.
local repo_dir = debug.getinfo(1, "S").source:match("^@(.*)/")
  or (os.getenv("HOME") .. "/omarchy-supplement")

-- Lid switch handling is left to Omarchy's stock bindings (see
-- $OMARCHY_PATH/default/hypr/bindings/utilities.lua). Those disable the
-- internal panel ONLY when an external monitor is actually connected, so a bare-
-- laptop lid-close suspends cleanly and the screen comes back on resume.
--
-- The unconditional overrides below disabled eDP-1 (the only display) on every
-- lid-close, leaving a black screen after suspend/resume. Kept commented for
-- reference — do NOT re-enable on a laptop without an always-connected external.
-- o.bind("switch:on:Lid Switch", nil, function() hl.monitor({ output = "eDP-1", disabled = true }) end, { locked = true })
-- o.bind("switch:off:Lid Switch", nil, function() hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 2 }) end, { locked = true })

o.bind("SUPER + D", "Discord", { webapp = "https://discord.com/channels/@me" })

-- SUPER + C is Omarchy's universal copy; SUPER + K is its keybindings menu.
hl.unbind("SUPER + C")
o.bind("SUPER + C", "Show key bindings", "omarchy-menu-keybindings")

o.bind("SUPER + B", "Browser", { launch = browser })

-- Move focus with vim keys. SUPER + J/K/L are bound by Omarchy's defaults
-- (toggle split, keybindings menu, toggle workspace layout).
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))

hl.config({
  misc = {
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
  },

  input = {
    -- Use multiple keyboard layouts and switch between them with Alt + Space.
    -- kb_layout = "us,dk",
    -- kb_options = "compose:caps,grp:alt_space_toggle",
    kb_options = "ctrl:nocaps",

    -- Change speed of keyboard repeat.
    repeat_rate = 50,
    repeat_delay = 220,

    -- Increase sensitivity for mouse/trackpad (default: 0).
    -- sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling.
      -- natural_scroll = true,
      disable_while_typing = true,

      -- Use two-finger clicks for right-click instead of lower-right corner.
      -- clickfinger_behavior = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.4,
    },
  },
})