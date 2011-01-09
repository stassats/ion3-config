dopath("mod_ionflux")
dopath("mpd")

defbindings("WMPlex", {
	       kpress("Mod4+r", "ioncore.exec_on(_, 'urxvtcd -e screen -dRR pts-0.slack')"),
               kpress("Mod4+Mod1+r", 
                      "ioncore.exec_on(_, 'urxvtcd -e ssh -tX slack LANG=ru_RU.UTF-8 screen -dRR')"),
	       kpress("Mod4+e", "ioncore.exec_on(_, 'emacs')"),
	       kpress("Mod4+f", "ioncore.exec_on(_, 'firefox')"),
	       kpress("Mod4+o", "ioncore.exec_on(_, 'opera')"),
               kpress("Mod4+c", "ioncore.exec_on(_, 'chrome')"),
	       kpress("Mod4+d", "ioncore.exec_on(_, 'okular')"),

	       kpress("Mod4+z", "dict_lookup(_)"),

               kpress("XF86Mail", "ioncore.exec('sleep 0.1;  xset dpms force standby')"),
               kpress("Scroll_Lock", "toggle_display()")
	    })

function toggle_display()
   status = os.execute("/home/stas/c/bin/toggle-displays")

   if status == 0 then
      ioncore.restart()
   end
end

function dict_lookup (ws)
   ioncore.request_selection(
      function (str)
	 local stream = io.popen("gosh ~/c/bin/idict \""..str.."\"")
	 local string = ""

	 for line in stream:lines() do
	    string = string..line.."\n"
	 end
	 stream:close()

	 mod_query.message(ws, string)
      end)
end
