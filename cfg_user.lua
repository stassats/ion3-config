dopath("mod_ionflux")
dopath("mpd")

function get_hostname()
   local out = io.popen("hostname")
   return out:read()
end

defbindings("WMPlex", {
	       kpress("Mod4+r", "ioncore.exec_on(_, 'urxvtcd -e screen -dRR main')"),
               kpress("Mod4+Mod1+r", 
                      "ioncore.exec_on(_, 'urxvtcd -e ssh -tX slack LANG=ru_RU.UTF-8 screen -dRR')"),
	       kpress("Mod4+e", "ioncore.exec_on(_, 'emacs')"),
	       kpress("Mod4+f", "ioncore.exec_on(_, 'firefox')"),
	       kpress("Mod4+o", "ioncore.exec_on(_, 'opera')"),
               kpress("Mod4+c", "ioncore.exec_on(_, 'chrome')"),
	       kpress("Mod4+d", "ioncore.exec_on(_, 'okular')"),

	       kpress("Mod4+z", "dict_lookup(_)"),

               kpress("Print", "ioncore.exec('sleep 0.1;  xset dpms force off')"),
               kpress("Scroll_Lock", "toggle_display(_)"),
               kpress("Control+F4", "ioncore.exec('susp')"),
               kpress("Mod4+F2", "repl(_)"),
               kpress("Mod4+F5", "start_all(_)"),
               -- kpress("XF86WWW", "show_weather()")
	    })

function start_all(ws)
   ioncore.exec_on(ws, 'emacs')
   ioncore.exec_on(ws, 'browser')
   ioncore.exec_on(ws, 'gnus')
   ioncore.exec_on(ws, 'urxvtcd -e screen -dRR main')
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

function mod_query.query_lua(mplex)
    local env=mod_query.create_run_env(mplex)
    
    local function complete(cp, code)
        cp:set_completions(mod_query.do_complete_lua(env, code))
    end
    
    local function handler(mplex, code)
        return mod_query.do_handle_lua(mplex, env, code)
    end
    
    mod_query.query(mplex, TR("Lua code:"), nil, handler, complete, "lua")
 end

function do_handle_lua(mplex, env, code)
    local print_res
    local function collect_print(...)
        local tmp=""
        local arg={...}
        local l=#arg
        for i=1,l do
            tmp=tmp..tostring(arg[i])..(i==l and "\n" or "\t")
        end
        print_res=(print_res and print_res..tmp or tmp)
    end

    local f, err=loadstring(code)
    if not f then
        mod_query.warn(mplex, err)
        return
    end
    
    env.print=collect_print
    setfenv(f, env)

    local result
    err=collect_errors(function () result = f() end)

    if err then
        mod_query.warn(mplex, err)
    elseif print_res then
       mod_query.message(mplex, print_res .. "\nResult: "..tostring(result))
    end
end

function repl(ws)
   local env=mod_query.create_run_env(ws)

   local function complete(cp, code)
        cp:set_completions(mod_query.do_complete_lua(env, code))
     end
   
   local function handler(mplex, code)
      return do_handle_lua(mplex, env, code)
   end

   mod_query.query(ws, "LUA: ", nil, handler, complete, "lua")
end


function move_scratch(x, y, w, h)
   ioncore.lookup_region("*scratchpad*"):rqgeom({x=x, y=y, w=w, h=h})
end

function get_display()
   local out = io.popen("xrandr")
   local line = out:read()
   
   while line do
      local b, e, id = string.find(line, "^(%w.+) connected %d+x%d+")

      if id then
         return id
      end

      line = out:read()
   end
end

function toggle_display(ws)
   local status
   local offset

   if  get_display() == "HDMI-0" then
      status = os.execute("xrandr --output HDMI-0 --off --output DVI-I-1 --auto && sleep 0.3 && xrandr --output DVI-D-0 --auto --output DVI-D-0 --left-of DVI-I-1 && xset dpms 600 600 600")
   else
      status = os.execute("xrandr --output DVI-I-1 --off && sleep 0.3 && xrandr --output DVI-D-0 --off --output HDMI-0 --auto && xset s off s noblank dpms 0 0 0 -dpms")
   end
   
   if status == 0 then
      move_scratch(0,0,20,30)
      ioncore.restart()
   end
end

function resize_scratch()
   if get_display() == "HDMI-0" then
      move_scratch(300, 160, 1361, 744)
   else
      move_scratch(2200, 260, 1361, 744)
   end
end

ioncore.get_hook("ioncore_post_layout_setup_hook"):add(resize_scratch)
