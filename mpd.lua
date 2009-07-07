defbindings("WMPlex", {
	       kpress("Mod4+BackSpace", "mpd_command('stop')"),
	       kpress("Mod4+p", "mpd_command('toggle')"),

	       kpress("Mod4+period", "mpd_command('next', status)"),
	       kpress("Mod4+comma", "mpd_command('prev', status)"),

               kpress("XF86Forward", "mpd_command('+5', volume)"),
	       kpress("XF86Back", "mpd_command('-5', volume)"),

               kpress("Mod4+i", "inform_mpd(status())"),
            })

function status(command)
   local mpd = io.popen("mpc --format '[%track%) %artist% - %title% (%album%; %date%)]|[%file%]' " ..
         (command or ""))
   if mpd == nil then
      return "MPD is not running."
   end

   local data = mpd:read()

   if data == nil or string.sub(data, 1, 6) == 'volume' then
      mpd:close()
      return "No song is playing."
   end

   local song = data

   data = mpd:read()
   mpd:close()

   if data == nil then
      return "Error..."
   end

   if string.sub(data, 1, 8) == "[paused]" then
      paused = "[Paused] "
   else
      paused = ""
   end

   local b, e = string.find(data, "%d+:%d+/%d+:%d+")
   local time = string.sub(data, b, e)

   b, e = string.find (data, "#%d+/%d+")
   local position = string.sub(data, b, e)

   return paused .. song .. " [" .. time .. "] " .. position
end

function volume(amount)
   local mpd = io.popen("mpc volume " .. amount)
   if mpd == nil then
      return "MPD is not running."
   end

   local data = mpd:read()

   if data == nil then
      mpd:close()
      return "MPD is not running."
   end

   if string.sub(data, 1, 6) ~= 'volume' then
      mpd:read()
      data = mpd:read()
   end
   mpd:close()

   return string.sub(data, 0, 11)
end

local function clear_mpd ()
   mod_statusbar.inform("mpd", "")
   mod_statusbar.update()
end

local timer = ioncore.create_timer()

function inform_mpd(text)
   mod_statusbar.inform("mpd", text)
   mod_statusbar.update()

   timer:set(3500, clear_mpd)
end

function mpd_command(command, inform)
   if inform == volume then
      inform_mpd(volume(command))
   elseif inform == status then
      inform_mpd(status(command))
   else
      ioncore.exec("mpc " .. command)
   end
end
