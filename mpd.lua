
local function get_mpd_status()
   local mpd = io.popen("mpc --format '[%artist% - %title% (%album%; %date%)]|[%file%]'")
   if mpd == nil then
      return "No song playing"
   end

   local data = mpd:read()

   if data == nil or string.sub(data, 1, 6) == 'volume' then
      mpd:close()
      return "No song playing"
   end

   local song = data

   data = mpd:read()
   mpd:close()

   if data == nil then
      return "Error.."
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

local function clear_mpd ()
   mod_statusbar.inform("mpd", "")
   mod_statusbar.update()
end

local timer = ioncore.create_timer()
function display_mpd()
   mod_statusbar.inform("mpd", get_mpd_status())
   mod_statusbar.update()

   timer:set(3500, clear_mpd)
end

function mpd_command(command, inform)
   local pid = ioncore.exec("mpc " .. command)

   if inform then
      ioncore.get_hook("ioncore_sigchld_hook"):add(
         function(p)
            if pid == p.pid then
               display_mpd()
            end
            ioncore.get_hook("ioncore_sigchld_hook"):remove(self)
         end
      )
   end
end