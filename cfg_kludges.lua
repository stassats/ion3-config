--
-- Options to get some programs work more nicely (or at all)
--

-- defwinprop{
--    class = "Xpdf",
--    instance = "openDialog_popup",
--    ignore_cfgrq = true,
-- }


-- Put all dockapps in the statusbar's systray, also adding the missing
-- size hints necessary for this to work.
defwinprop{
   is_dockapp = true,
   statusbar = "systray",
   max_size = { w = 64, h = 64},
   min_size = { w = 64, h = 64},
}

defwinprop{
   class = "Firefox",
   target = "browser",
}
defwinprop{
   class = "Iceweasel",
   target = "browser",
}

defwinprop{
   class = "Opera",
   instance = "opera",
   target = "browser",
}
defwinprop{
   class = "OperaNext",
   instance = "opera",
   target = "browser",
}
defwinprop{
   class = "Chrome",
   target = "browser",
}
defwinprop{
   class = "Emacs",
   instance = "emacs",
   target = "emacs",
}

defwinprop{
   class = "Emacs",
   instance = "emacs",
   name = "Question",
   float = true,
}

defwinprop{
   class = "Emacs",
   instance = "emacs",
   name = "GNUS",
   target = "gnus",
}

defwinprop{
   class = "URxvt",
   instance = "urxvt",
   name = "screen",
   target = "*scratchws*",
}

defwinprop{
   class = "URxvt",
   instance = "urxvt",
   name = "stas*",
   target = "main",
}
-- defwinprop{
--    class = "Okular",
--    target = "5",
-- }
