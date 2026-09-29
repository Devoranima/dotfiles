-- ~/.config/hypr/hyprland.lua
-- Converted from the legacy hyprland.conf (hyprlang) format.
-- Docs: https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

-- monitor=,preferred,auto,1
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- hl.monitor({ output = "eDP-1", mode = "2240x1440@60", position = "0x0", scale = 1 })

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- Was `$HYPRSHOT_DIR = ...` in the old config. That was a hyprlang *variable*,
-- which hyprshot never actually saw; as a real env var it now works.
hl.env("HYPRSHOT_DIR", os.getenv("HOME") .. "/Pictures/Screenshots")

-------------------
---- AUTOSTART ----
-------------------

-- exec-once -> run once at compositor startup
hl.on("hyprland.start", function()
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/xdg-portal-hyprland") -- make sure the correct portal is running
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("waybar")             -- the top bar
    hl.exec_cmd("blueman-applet")     -- systray app for BT
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/bgaction") -- sets the background based on theme
    hl.exec_cmd("xrandr --output eDP-1 --primary")
    ---    hl.exec_cmd("hyprpaper")
end)

-- exec -> runs every time this file is executed (startup *and* config reload)
-- hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/bgaction") -- sets the background based on theme

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    debug = {
        disable_logs = false,
    },

    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 1,
        col = {
            -- Hairline outlines: same hue as before (cdd6f4), just barely
            -- there at rest and brightening a bit on focus.
            active_border   = "rgba(cdd6f466)",
            inactive_border = "rgba(cdd6f41a)",
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 3,
        shadow = {
            enabled        = true,
            range          = 10,
            render_power   = 2,
            color          = "rgba(00000066)",
            color_inactive = "rgba(00000026)",
        },
        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            new_optimizations = true,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        key_press_enables_dpms   = true,
        middle_click_paste       = false,
    },

    dwindle = {
        -- pseudotile     = true,
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    input = {
        kb_layout  = "us, ru",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification

        touchpad = {
            natural_scroll = true,
            drag_lock      = 1, -- now an int: 0 = off, 1 = timeout, 2 = sticky
        },
    },
})

----------------------
---- ANIMATIONS ------
----------------------

hl.curve("myBezier", { type = "bezier", points = { { 0.10, 0.9 }, { 0.1, 1.05 } } })
hl.curve("quietOut", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

-- Quick, soft fade/scale so things arrive and dissolve rather than slide
-- in like UI chrome -- the "ephemeral" part.
hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "quietOut", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "myBezier", style = "popin 92%" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "quietOut", style = "fade" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3, bezier = "quietOut", style = "fade" })

-- Same glass treatment on the bar/launcher/notifications so nothing looks
-- like an opaque panel dropped on top of the desktop.
for _, ns in ipairs({ "waybar", "wofi", "notifications", "logout_dialog" }) do
    hl.layer_rule({
        name        = "blur-" .. ns,
        match       = { namespace = ns },
        blur        = true,
        ignore_alpha = true,
    })
end

----------------------
---- WINDOW RULES ----
----------------------

local floatByClass = { "pavucontrol", "blueman-manager", "nm-connection-editor", "chromium", "thunar" }
for _, class in ipairs(floatByClass) do
    hl.window_rule({
        name  = "float-" .. class,
        match = { class = "^(" .. class .. ")$" },
        float = true,
    })
end

hl.window_rule({ name = "float-btop",       match = { title = "^(btop)$" },       float = true })
hl.window_rule({ name = "float-update-sys", match = { title = "^(update-sys)$" }, float = true })

-- kitty handles its own background_opacity (text stays fully opaque, only
-- the backdrop is glassy) so it gets no compositor-level opacity rule here --
-- stacking both is what makes a terminal unreadable. GTK apps don't have
-- that per-pixel trick, so they keep only a light, legible translucency.
hl.window_rule({ name = "opacity-thunar",   match = { class = "^(thunar)$" },     opacity = "0.95 0.9" })
hl.window_rule({ name = "opacity-vscodium", match = { class = "^(VSCodium)$" },   opacity = "0.96 0.92" })

hl.window_rule({
    name      = "popin-update-sys",
    match     = { class = "^(kitty)$", title = "^(update-sys)$" },
    animation = "popin",
})
hl.window_rule({ name = "popin-thunar",  match = { class = "^(thunar)$" },  animation = "popin" })
hl.window_rule({ name = "popin-firefox", match = { class = "^(firefox)$" }, animation = "popin" })
hl.window_rule({ name = "slide-wofi",    match = { class = "^(wofi)$" },    animation = "slide" })

hl.window_rule({ name = "float-vscodium-open", match = { class = "^(VSCodium)$", title = "^(Open .*)$" }, float = true })
hl.window_rule({ name = "float-vscodium-save", match = { class = "^(VSCodium)$", title = "^(Save .*)$" }, float = true })

hl.window_rule({
    name  = "move-clippick",
    match = { class = "^(wofi)$", title = "^(clippick)$" },
    move  = "100%-433 53",
})

hl.window_rule({
    name   = "nmtui",
    match  = { title = "^(nmtui)$" },
    float  = true,
    size   = "600 400",
    center = true,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))                            -- open the terminal
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.window.close())                       -- close the active window
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))                         -- lock the screen
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("wlogout --protocol layer-shell"))   -- logout window
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())                               -- quit Hyprland
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("wofi"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())                              -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))                        -- dwindle
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("sh " .. os.getenv("HOME") .. "/.config/hypr/scripts/toggle_float"))

-- Screenshots
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("hyprshot -m window"))

-- Move focus with mainMod + arrow keys
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
end

-- Switch workspaces / move active window to a workspace
for i = 1, 10 do
    local key = i % 10 -- workspace 10 lives on key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize the active window (repeating + locked, was `bindel`)
local resizeOpts = { repeating = true, locked = true }
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), resizeOpts)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -20, y = 0, relative = true }), resizeOpts)
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0, y = -20, relative = true }), resizeOpts)
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0, y = 20, relative = true }), resizeOpts)

-- Move the active window between tiles
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + CTRL + " .. dir, hl.dsp.window.move({ direction = dir }), resizeOpts)
end

-- Laptop lid
hl.bind("switch:on:Lid Switch",
    hl.dsp.exec_cmd("loginctl lock-session && hyprctl dispatch dpms off"), { locked = true })
hl.bind("switch:off:Lid Switch",
    hl.dsp.exec_cmd("sleep 1 && hyprctl dispatch dpms on"), { locked = true })

-- Audio
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume -2"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume +2"), { repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Brightness
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness -10"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness +10"))

-- Misc hardware keys
hl.bind("XF86Display", hl.dsp.exec_cmd("wdisplays"))
hl.bind("XF86WLAN", hl.dsp.exec_cmd("nmcli radio wifi toggle"))
hl.bind("XF86NotificationCenter", hl.dsp.exec_cmd("bluetooth toggle"))
hl.bind("XF86PickupPhone", hl.dsp.exec_cmd("playerctl play-pause"))
-- hl.bind("XF86HangupPhone", function() hl.print("HANGUP") end)
-- hl.bind("XF86Favorites", function() hl.print("FAV") end)

-- Split this file up when it gets long:
-- require("mycolors")
