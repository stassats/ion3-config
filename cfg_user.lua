dopath("mod_ionflux")

defbindings("WMPlex", {
	       kpress("Mod4+r", "ioncore.exec_on(_, 'urxvtcd -e screen -dRR')"),
               kpress("Mod4+Mod1+r", "ioncore.exec_on(_, 'urxvtcd -e ssh slack -X')"),
	       kpress("Mod4+e", "ioncore.exec_on(_, 'emacs')"),
	       kpress("Mod4+f", "ioncore.exec_on(_, 'firefox')"),
	       kpress("Mod4+o", "ioncore.exec_on(_, 'opera')"),

	       -- mpd
	       kpress("Mod4+BackSpace", "ioncore.exec_on(_, 'mpc stop')"),
	       kpress("Mod4+p", "ioncore.exec_on(_, 'mpc toggle')"),
	       kpress("Mod4+period", "ioncore.exec_on(_, 'mpc next')"),
	       kpress("Mod4+comma", "ioncore.exec_on(_, 'mpc prev')"),
	       kpress("Mod4+i", "mpd_now_playing(_)"),

	       kpress("Mod4+z", "dict_lookup(_)"),
	    })

function dict_lookup (ws)
   ioncore.request_selection(
      function (str)
	 local stream = io.popen("gosh ~/c/bin/idict "..str)
	 local string = ""

	 for line in stream:lines() do
	    string = string..line.."\n"
	 end
	 stream:close()

	 mod_query.message(ws, string)
      end)
end

local function mpd_get_status()

   local mpd = io.popen("mpc --format '[%artist% - %title% (%album%)]|[%file%]'")
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

   local b, e = string.find (data, "%d+:%d+/%d+:%d+")
   local time = string.sub(data, b, e)

   b, e = string.find (data, "#%d+/%d+")
   local position = string.sub(data, b, e)

   return paused .. position .. ": " .. song .. " [" .. time .. "]"
end

function mpd_now_playing (ws)
   mod_query.message(ws, mpd_get_status())
end
