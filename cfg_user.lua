dopath("mod_ionflux")
dopath("mpd")

defbindings("WMPlex", {
	       kpress("Mod4+r", "ioncore.exec_on(_, 'urxvtcd -e screen -dRR')"),
               kpress("Mod4+Mod1+r", "ioncore.exec_on(_, 'urxvtcd -e ssh slack -X')"),
	       kpress("Mod4+e", "ioncore.exec_on(_, 'emacs')"),
	       kpress("Mod4+f", "ioncore.exec_on(_, 'firefox')"),
	       kpress("Mod4+o", "ioncore.exec_on(_, 'opera')"),

	       -- mpd
	       kpress("Mod4+BackSpace", "mpd_command('stop')"),
	       kpress("Mod4+p", "mpd_command('toggle')"),
	       kpress("Mod4+period", "mpd_command('next', true)"),
	       kpress("Mod4+comma", "mpd_command('prev', true)"),
	       kpress("Mod4+i", "display_mpd()"),
               kpress("XF86Forward", "mpd_command('volume +5')"),
	       kpress("XF86Back", "mpd_command('volume -5')"),

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
