-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local daze = require("daze")
local vicious = require("vicious")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}



-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/phallus/.config/awesome/themes/benis/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
browser = os.getenv("BROWSER") or "firefox"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
scrot = "~/bin/scr"
lock = "~/bin/i3lock-w"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    daze.layout.tile,
}

-- }}}



-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "⮫", "⮬", "⮭", "⮮", "⮯" }, s, layouts[1])
end

awful.layout.set(awful.layout.suit.floating, tags[1][1])                                             
awful.tag.setmwfact(0.658, tags[1][1])
awful.tag.setncol(1, tags[1][1])

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "⮗ awesome", awesome.restart },
                                    { "⮩ urxvtc", terminal },
				    { "⮠ nitrogen", "nitrogen" },
				    { "⮤ scrot", "/home/phallus/bin/scr" },
				    { "⮪ lock", "/home/phallus/bin/i3lock-w" }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}




-- {{{ Tasklist

tasklist = {}
tasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
        end
        client.focus = c
        c:raise()
    end
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end)
)

--}}}




-- {{{ Wibox

	
-- bat widget

batwidget = wibox.widget.textbox()
daze.widgets.bat.register(batwidget)
function batinfo(adapter)
          local fcur = io.open("/sys/class/power_supply/"..adapter.."/energy_now")    
          local fcap = io.open("/sys/class/power_supply/"..adapter.."/energy_full")
          local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
          local cur = fcur:read()
          local cap = fcap:read()
          local sta = fsta:read()
          local battery = math.floor(cur * 100 / cap)
          local batico = ""
          if sta:match("Charging") then
            batico = "<span color='#dfdfdf'>⮒ </span>"
	    batstat = "charging @ "
	    batwidget:set_markup(' '..batico..''..batstat..'' ..battery..'% ')
          elseif sta:match("Discharging") then
	    batstat = "discharging @ "
            if tonumber(battery) > 49 then
              batico = "<span color='#dfdfdf'>⮏ </span>"
            elseif tonumber(battery) < 50 and tonumber(battery) > 20 then
              batico = "<span color='#dfdfdf'>⮑ </span>"
            else
              batico = "<span color='#c97c7c'>⮐ </span>"
            end
	    batwidget:set_markup(' '..batico..''..batstat..'' ..battery..'% ')
          else
	    batstat = "charged "	
            batico = "<span color='#dfdfdf'>⮎ </span>"
	    batwidget:set_markup(' '..batico..''..batstat..'')	
          end
          fcur:close()
          fcap:close()
          fsta:close()
        end
     
        battery_timer = timer({timeout = 1})
        battery_timer:connect_signal("timeout", function()
          batinfo("BAT0")
        end)
        battery_timer:start()




-- time widget
mytextclock = awful.widget.textclock("  <span color='#dfdfdf'>⮖</span> %R - %a, %b %d ")
daze.widgets.calendar.register(mytextclock)


-- mpd widget
mpdwidget = wibox.widget.textbox()                                                                                                                   
daze.widgets.mpd.register(mpdwidget)

-- Register widget
vicious.register(mpdwidget, vicious.widgets.mpd,
   function (widget, args)
       if args["{state}"] == "Stop" then 
           return "<span color='#dfdfdf'>⮕</span> [mpd stopped]"
       elseif args["{state}"] == "Pause" then
		   return '<span color="#dfdfdf">⮔</span> '.. args["{Title}"]..'<span color="#d2d2d2"> by </span>'.. args["{Artist}"]..''
       else
  		   return '<span color="#dfdfdf">⮓</span> '.. args["{Title}"]..'<span color="#d2d2d2"> by </span>'.. args["{Artist}"]..''
       end
   end, 1)

-- layout widget
function updatelayoutbox(l, s)
    local screen = s or 1
    l.text = beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(screen))]
end


separator = wibox.widget.textbox()
spacer = wibox.widget.textbox("     ")
separator:set_text("")


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
txtlayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                    )

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = false
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    txtlayoutbox[s] = wibox.widget.textbox()
    txtlayoutbox[s].text = beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(s))] 
    awful.tag.attached_connect_signal(s, "property::selected", function ()
        updatelayoutbox(txtlayoutbox[s], s) 
    end)
    awful.tag.attached_connect_signal(s, "property::layout", function ()
        updatelayoutbox(txtlayoutbox[s], s) 
    end)
    txtlayoutbox[s]:buttons(awful.util.table.join(
            awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
            awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
            awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
            awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))
 
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
--    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.focused, mytasklist.buttons)
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 10 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(txtlayoutbox[s])
    left_layout:add(spacer)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(spacer)
    right_layout:add(separator)
    right_layout:add(mpdwidget)
    right_layout:add(separator)
    right_layout:add(mytextclock)
    right_layout:add(separator)
    right_layout:add(batwidget)

-- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)
    mywibox[s]:set_widget(layout)
end
-- }}}





-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- }}}





-- Client mode
-- Move floating windows 5 pixels at a time

function floats(c)
	local ret = false
	local layout = awful.layout.get(c.screen)
	if awful.layout.getname(layout) == "floating" or awful.client.floating.get(c) then
		ret = true
	end
	return ret
end

function move(c, x, y)
	if not floats(c) then
		return
	end

local g = c:geometry()
	g.x = g.x + x
	g.y = g.y + y
	c:geometry(g)
end

client_mode = {
	k = function(c) move(c, 0, -5) end, -- Up
	j = function(c) move(c, 0, 5) end, -- Down
	h = function(c) move(c, -5, 0) end, -- Left
	l = function(c) move(c, 5, 0) end, -- Right
	u = function(c) move(c, -5, -5) end, -- Up left
	i = function(c) move(c, 5, -5) end, -- Up right
	n = function(c) move(c, -5, 5) end, -- Down left
	m = function(c) move(c, 5, 5) end, -- Down right
}

client_mode_common = {
-- Various controls
	f = function (c) c.fullscreen = not c.fullscreen end,
	x = function (c)
	c.maximized_horizontal = not c.maximized_horizontal
	c.maximized_vertical = not c.maximized_vertical
	end,
-- Launch terminal
	q = function()
	awful.util.spawn(terminal)
	end
}

client_mode = awful.util.table.join(client_mode, client_mode_common)


-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "j",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "k",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "l",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "h",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, 	  }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, }, "n", function () awful.util.spawn("firefox") end),
    awful.key({ "Control" }, "l", function () awful.util.spawn("mpc next") end), 
    awful.key({ "Control" }, "j", function () awful.util.spawn("amixer -q set Master 4%- unmute") end),
    awful.key({ "Control" }, "k", function () awful.util.spawn("amixer -q set Master 4%+ unmute") end),
    awful.key({ "Control" }, "h",  function () awful.util.spawn("mpc prev") end),
    awful.key({ modkey, }, "p", function () awful.util.spawn("mpc toggle") end),

    -- Prompt
    -- awful.key({ modkey },            "d", awful.util.spawn("dmenu_run -p 'run' -fn '-*-lemon-*-*-*-*-10-*-*-*-*-*-*-*' -nf '#a2a2a2' -nb '#131313' -sf '#777777' -sb '#131313")),
    --    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
--    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "t",      awful.client.floating.toggle                  ),
    awful.key({ modkey,           }, "m",      function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "y",      function (c) c.ontop = not c.ontop            end))
    awful.key({ modkey, }, "o", function (c)
                                                   if c.border_width == 0 then
                                                       c.border_width = beautiful.border_width
                                                       awful.layout.set(awful.layout.get(), tags[1][1])
                                                   else
                                                       c.border_width = 0
                                                       awful.layout.set(awful.layout.get(), tags[1][1])
                                                   end
                                               end )	

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    { rule = { }, properties = { }, callback = awful.client.setslave },
    { rule = { class = "feh" },
      properties = { border_color = beautiful.border_feh,
        floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "sun-awt-X11-XWindowPeer" },
      properties = { floating = true, border_width = 0 } },
    { rule = { instance = "Download" },
      properties = { floating = true } },
    { rule = { instance = "Devtools" },
      properties = { floating = true } },

      
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.center_horizontal(c)
            awful.placement.center_vertical(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

