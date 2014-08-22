import XMonad
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import Graphics.X11.ExtraTypes.XF86
-- Actions.*
import qualified XMonad.Actions.FlexibleManipulate as Flex
import XMonad.Actions.GridSelect
-- Hooks.*
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
-- Layout.*
import XMonad.Layout.NoBorders (smartBorders)
-- System.*
import System.Exit
import System.IO
-- Util.*
import XMonad.Util.EZConfig (mkKeymap)
import XMonad.Util.Run (spawnPipe, safeSpawn)
import XMonad.Util.Scratchpad

main :: IO ()
main = xmonad =<< statusBar bar pp togstr conf
    where
        uhook  = withUrgencyHookC NoUrgencyHook urgentConfig
        bar    = "xmobar"
        pp     = _PP
        togstr = toggleStrutsKey
        conf   = uhook _Config

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------
_Config = defaultConfig { keys          = _Keys
                        , layoutHook    = smartBorders $ layoutHook defaultConfig
                        , manageHook    = _ManageHook
                        , modMask       = _ModMask
                        , mouseBindings = _MouseBindings
                        , terminal      = _Terminal
                        , workspaces    = _Workspaces
                        }

-------------------------------------------------------------------------------
-- pretty-printing for workspace switcher
-------------------------------------------------------------------------------
_PP = defaultPP { ppCurrent         = xmobarColor "#5283d7" "" . wrap "<" ">"
                , ppHidden          = xmobarColor "#ffc442" ""
                , ppHiddenNoWindows = xmobarColor "#161616" ""
                , ppUrgent          = xmobarColor "#b698d9" "" . wrap "[" "]"
                , ppSep             = xmobarColor "#ffc442" "" " : "
                , ppSort            = fmap (.scratchpadFilterOutWorkspace) $ ppSort defaultPP
                , ppTitle           = xmobarColor "#ffc442" "" . shorten 60
                , ppLayout          = xmobarColor "#ffc442" ""
                , ppOrder           = \(ws:_:t:_) -> [ws,t]
                }

-------------------------------------------------------------------------------
-- Main Config
-------------------------------------------------------------------------------
-- %% Window Management
_ManageHook = composeAll [ isFullscreen           --> doFullFloat
                         , className =? "mpv"     --> doFloat
                         , className =? "Gimp"    --> doFloat
                         --, className =? "Firefox" --> doF (W.shift (_Workspaces !! 1))
                         --, className =? "Firefox" <&&> resource =? "Dialog") --> doFloat
                         ] <+> _ScratchPad

_ScratchPad :: ManageHook
_ScratchPad = scratchpadManageHook (W.RationalRect l t w h)
              where
                  h = 0.4
                  w = 0.4    -- width/height, 30%
                  t = 1 - h
                  l = 1 - w  -- place in lower right
-- %% Vars
_ModMask    = mod4Mask
_Terminal   = "urxvtc"
_Workspaces = ["1 terms", "2 web"] ++ map show [3..9]

-- %% Keybindings
_Keys c = mkKeymap c $
      -- launch/kill programs
      [ ("M-<Return>"   , safeSpawn (XMonad.terminal c) [] )
      , ("M-<Space>"    , scratchpadSpawnActionTerminal _Terminal)
      , ("M-d"          , safeSpawn "dmenu-yeganesh" [])
      , ("M-S-d"        , safeSpawn "gmrun" [])
      , ("M-S-c"        , kill)

      , ("M-C-<Space>"  , sendMessage NextLayout)
      , ("M-S-<Space>"  , setLayout $ XMonad.layoutHook c)

      , ("M-n"          , refresh)

      -- multimedia keys
      , ("<XF86MonBrightnessUp>",   safeSpawn "xbacklight" ["+20"])
      , ("<XF86MonBrightnessDown>", safeSpawn "xbacklight" ["-20"])
      -- personal launch codes
      , ("M-S-w"        , safeSpawn "chromium" ["--incognito"])
      , ("<Insert>"     , safeSpawn "screenshot" [])
      , ("C-<Insert>"   , safeSpawn "screenshot" ["-s"])
      , ("<Print>"      , spawn "iocane -c 'b 2'")

      -- move focus
      , ("M-Tab"        , windows W.focusDown)
      , ("M-S-Tab"      , windows W.focusUp)
      , ("M-j"          , windows W.focusDown)
      , ("M-k"          , windows W.focusUp)
      , ("M-m"          , windows W.focusMaster)

      -- modify the window order
      , ("M-S-<Return>" , windows W.swapMaster)
      , ("M-S-j"        , windows W.swapDown)
      , ("M-S-k"        , windows W.swapUp)

      -- adjust master/slave ratio
      , ("M-h"          , sendMessage Shrink)
      , ("M-l"          , sendMessage Expand)

      -- float window
      , ("M-t"          , withFocused $ windows . W.sink)

      -- increase/decrease number of windows in the master area
      , ("M-,"          , sendMessage (IncMasterN 1))
      , ("M-."          , sendMessage (IncMasterN (-1)))

      , ("M-S-q"        , io (exitWith ExitSuccess))
      , ("M-q"          , broadcastMessage ReleaseResources
                          >> restart "xmonad" True)
      ] ++
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      [ (m ++ k, windows $ f w)
           | (w, k) <- zip (XMonad.workspaces c) (map show [1..9])
           , (m, f) <- [("M-", W.greedyView), ("M-S-", W.shift)]
      ]

-- %% Mousebindings
_MouseBindings :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
_MouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList
      -- mod-button1: set window to floating and move by dragging
      [ ((modMask, button1), \w -> focus w >> mouseMoveWindow w
                                           >> windows W.shiftMaster)
      -- mod-button2: raise window to top of stack
      , ((modMask, button2), windows . (W.shiftMaster .) . W.focusWindow)
      -- mod-button3: set window to floating and resize by dragging
      , ((modMask, button3), Flex.mouseWindow Flex.discrete)
      , ((modMask, button4), const $ windows W.swapDown)
      , ((modMask, button5), const $ windows W.swapUp)
      ]

-------------------------------------------------------------------------------
-- Set mod+b to toggle strut (i.e. xmobar).
-------------------------------------------------------------------------------
toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
urgentConfig = UrgencyConfig { suppressWhen = Focused, remindWhen = Dont}

-------------------------------------------------------------------------------
-- 
