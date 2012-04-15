--
-- My xmonad configuration file.
--
--

import XMonad
import XMonad.Prompt
import System.Exit
import XMonad.Config.Kde
import XMonad.Layout.Monitor
import XMonad.Hooks.ManageDocks -- For managing specific windows
import XMonad.Layout.Decoration -- For title bars for windows.
import XMonad.Layout.NoFrillsDecoration -- For title bars for windows.
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.NoBorders
import XMonad.Hooks.DynamicLog
import XMonad.Actions.DynamicWorkspaces -- For creating/deleting workspaces dynamically.
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.Themes
import System.IO
import XMonad.Hooks.SetWMName

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "konsole"

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
myNumlockMask   = mod2Mask

-- Workspaces

myWorkspaces = ["home", "web", "math"]


-- Border configurations
myBorderWidth   = 2
myNormalBorderColor  = "#000000"
myFocusedBorderColor = "#ffffff"


------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- launch a terminal
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modMask,               xK_r     ), spawn "dmenu_run")
    
    -- close focused window 
    , ((modMask .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modMask,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modMask,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modMask,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modMask,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modMask,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modMask,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modMask,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modMask,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modMask,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))

    -- toggle the status bar gap
    , ((modMask              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modMask              , xK_q     ), restart "xmonad" True)
    ]
    ++
    
    -- Workspace keybindings

    [
     ((modMask .|. shiftMask, xK_BackSpace), removeWorkspace)
    , ((modMask, xK_w), selectWorkspace defaultXPConfig)
    , ((modMask .|. shiftMask, xK_w), withWorkspace defaultXPConfig (windows . W.shift))
    , ((modMask .|. shiftMask, xK_r      ), renameWorkspace defaultXPConfig)
    ]

    ++
    -- mod-[1..9], Switch to workspace N
    --mod-shift-[1..9], Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
         | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
    , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    -- -- ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
--     [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
--         | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
--         , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--

myLayoutHook = smartBorders (avoidStruts $ noFrillsDeco shrinkText myDecoTheme (tiled ||| Mirror tiled ||| Full))
    where
      -- My SimpleDeco theme
      myDecoTheme = defaultTheme

      -- default tiling algorithm partitions the screen into two panes
      tiled   = Tall nmaster delta ratio
      -- The default number of windows in the master pane
      nmaster = 1
      -- Default proportion of screen occupied by master pane
      ratio   = 1/2
      -- Percent of screen to increment by when resizing panes
      delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll . concat $
               [ [className =? c --> doFloat | c <- myFloats],
                 [className =? c --> doIgnore | c <- myIgnores],
                 [resource  =? c --> doIgnore | c <- myIgnores]]
                   where
                     myFloats = ["SMPlayer", "MPlayer", "Gimp", "Krunner"]
                     myIgnores = ["desktop_window", "kdesktop", "trayer"]
--manageHook kde4Config <+>



-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True


------------------------------------------------------------------------
-- Dzen configuration
-- Notice the addition to logHook in the main function.
dzenSwitchWs :: String -> String
dzenSwitchWs s = "^ca(1,switch-workspaces.pl " ++ (show s) ++ ")" ++ s ++ "^ca()"

myDzenPPConfig :: Handle -> PP
myDzenPPConfig h = defaultPP
                   { ppOutput   = hPutStrLn h
                   , ppCurrent  = dzenColor "#f8f8f8" "DodgerBlue4" . pad
                   , ppVisible  = dzenColor "#f8f8f8" "LightSkyBlue4"
                                  . pad . dzenSwitchWs
                   , ppUrgent   = dzenColor "#f8f8f8" "red4" . pad . dzenSwitchWs . dzenStrip
                   , ppHidden   = pad . dzenSwitchWs
                   , ppLayout   = dzenColor "DarkOrange" "" . wrap "^ca(1,xdotool key Super_L+space)[" "]^ca()"
                   , ppTitle    = dzenColor "#61ce3c" "" . dzenEscape
                   , ppSep      = " "
                   , ppWsSep    = "|"
                   }

------------------------------------------------------------------------
-- Final loghook, including dzen and fading.
myLogHook :: X()
myLogHook = fadeInactiveLogHook fadeAmount >>
            setWMName "LG3D"
                where fadeAmount = 0.90

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  myDzenInstance <- spawnPipe "dzen2 -ta l -fg grey80 -bg grey20 -e 'button3='"
  xmonad $ ewmh defaultConfig {
      -- simple stuff
      terminal           = myTerminal,
      focusFollowsMouse  = myFocusFollowsMouse,
      borderWidth        = myBorderWidth,
      modMask            = myModMask,
      numlockMask        = myNumlockMask,
      workspaces         = myWorkspaces,
      normalBorderColor  = myNormalBorderColor,
      focusedBorderColor = myFocusedBorderColor,
      
      -- key bindings
      keys               = myKeys,
      mouseBindings      = myMouseBindings,

      -- hooks, layouts
      layoutHook         = myLayoutHook,
      manageHook         = manageHook kde4Config <+> myManageHook,
      logHook            = myLogHook >> (dynamicLogWithPP $ myDzenPPConfig myDzenInstance)
             }
         