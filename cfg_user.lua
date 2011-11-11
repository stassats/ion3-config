dopath("mod_ionflux")
dopath("mpd")

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

               kpress("Print", "ioncore.exec('sleep 0.1;  xset dpms force standby')"),
               kpress("Scroll_Lock", "toggle_display(_)"),
               kpress("Control+F4", "ioncore.exec('susp')"),
               kpress("Mod4+F2", "repl(_)"),
               -- kpress("XF86WWW", "show_weather()")
	    })

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

function get_resolution()
   local out = io.popen("xrandr")
   local line = out:read()
   
   while line do
      local b, e, w, h = string.find(line, "default connected (%d+)x(%d+)")

      if w and h then
         return tonumber(w), tonumber(h)
      end

      line = out:read()
   end
end

function toggle_display(ws)
   local w = get_resolution()
   local status

   if w == 3840 then
      status = os.execute("disper -d DFP-1 -e")
   else
      status = os.execute("disper -d DFP-2,DFP-0 -e")
   end
   
   if status == 0 then
      move_scratch(5,5,100,100)
      ioncore.restart()
   end
end

function resize_scratch()
   if get_resolution() == 3840 then
      move_scratch(2120, 100, 1600, 900)
   else
      move_scratch(200, 100, 1600, 900)
   end
end

ioncore.get_hook("ioncore_post_layout_setup_hook"):add(resize_scratch)
