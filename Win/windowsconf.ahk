;; AutoHotKey

; simulate i3wm or sway, switch to first(actually left) workspace
^1::
Send, #^{Left}
return

; switch to right workspace
^2::
Send, #^{Right}
return
; ---------- use Win+Tab to preview and create workspace ----------

; ---------- first maxmize current window, then Win+[ to hide title bar, mainly used for cygwin window
;-Caption
LWIN & [::
WinSet, Style, -0xC00000, A
return
;

; Win+] to restore title bar
;+Caption
LWIN & ]::
WinSet, Style, +0xC00000, A
return
;
