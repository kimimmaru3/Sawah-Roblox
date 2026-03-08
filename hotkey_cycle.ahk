#Requires AutoHotkey v2.0
#SingleInstance Force

; ========================================
; GLOBAL VARIABLES
; ========================================
global cycling := false
global holdDuration := 4000           ; Default 4 seconds
global delayBetweenCycles := 500      ; Default 500ms
global bindKey := "e"                 ; Default key
global clickCount := 2                ; Default number of clicks during delay
global cycleProgress := 0             ; Progress counter
global cycleCount := 0                ; Total cycles completed
global currentPhase := "idle"         ; Current phase: pressing or delay
global overlayGui := 0                ; GUI object
global settingsGui := 0               ; Settings GUI object

; Load saved settings
LoadSettings()

; Create main overlay
CreateOverlay()

; ========================================
; HOTKEY DEFINITIONS
; ========================================

; F3 - Toggle cycling on/off
F3::
{
    global cycling, overlayGui, settingsGui
    cycling := !cycling
    
    if (cycling)
    {
        overlayGui.Show()  ; Show overlay when cycling starts
        ; if the settings window is open, close it when cycling resumes
        if (settingsGui && IsObject(settingsGui))
        {
            try
                settingsGui.Destroy()
            settingsGui := 0
        }
    }
    else
    {
        overlayGui.Hide()  ; Hide overlay when cycling stops
        ShowSettingsMenu()
    }
}

; F4 - Exit program
F4::
{
    ExitApp()
}

; ========================================
; CREATE STATUS OVERLAY
; ========================================
CreateOverlay()
{
    global overlayGui
    
    overlayGui := Gui(, "SAWAH")
    overlayGui.Opt("+AlwaysOnTop +ToolWindow")
    overlayGui.BackColor := "ffffff"
    
    overlayGui.Add("Text", "w250 h80 c00ff00", "")
    overlayGui.Add("Progress", "x10 y20 w230 h20 c00ff00 -Smooth vProgressBar", 0)
    overlayGui.Add("Text", "x10 y50 w230 h20 c000000 vStatusText", "Status: WAITING")
    overlayGui.Add("Text", "x10 y75 w230 h20 c000000 vProgressText", "Progress: 0%")
    overlayGui.Add("Text", "x10 y100 w230 h20 c808080 vPhaseText", "Phase: idle")
    overlayGui.Add("Text", "x10 y125 w230 h20 c808080 vCycleCountText", "Cycles: 0")
    
    overlayGui.Show("w250 h160 x50 y50")
    overlayGui.Hide()  ; Hidden by default
    
    ; Update overlay
    SetTimer(UpdateOverlay, 100)
}

UpdateOverlay()
{
    global cycling, holdDuration, cycleProgress, overlayGui, currentPhase, cycleCount, bindKey
    
    if (!overlayGui)
        return
    
    if (cycling)
    {
        progress := (cycleProgress / holdDuration) * 100
        overlayGui["ProgressBar"].Value := Min(progress, 100)
        overlayGui["ProgressText"].Value := "Progress: " . Format("{:.0f}", progress) . "%"
        overlayGui["StatusText"].Value := "Status: ACTIVE"
        overlayGui["PhaseText"].Value := "Phase: " . currentPhase
        overlayGui["CycleCountText"].Value := "Cycles: " . cycleCount
    }
    else
    {
        overlayGui["ProgressBar"].Value := 0
        overlayGui["ProgressText"].Value := "Progress: 0%"
        overlayGui["StatusText"].Value := "Status: WAITING"
        overlayGui["PhaseText"].Value := "Phase: idle"
        overlayGui["CycleCountText"].Value := "Cycles: " . cycleCount
    }
}

; ========================================
; SETTINGS MENU
; ========================================
ShowSettingsMenu()
{
    global settingsGui, holdDuration, delayBetweenCycles, bindKey, clickCount
    
    if (settingsGui && IsObject(settingsGui))
    {
        try
            settingsGui.Destroy()
    }
    
    settingsGui := Gui(, "SAWAH")
    settingsGui.BackColor := "ffffff"
    settingsGui.TextColor := "000000"
    settingsGui.Opt("+AlwaysOnTop +Resize")
    
    settingsGui.Add("Text", "w300 h30 c808080", "Sawah")
    settingsGui.Add("Text", "w300 h20", "")
    
    settingsGui.Add("Text", "w300 h20", "Hold Duration (ms):")
    settingsGui.Add("Edit", "w150 h25 vHoldDurationInput", holdDuration)
    
    settingsGui.Add("Text", "w300 h20", "Delay Between Cycles (ms):")
    settingsGui.Add("Edit", "w150 h25 vDelayInput", delayBetweenCycles)
    
    settingsGui.Add("Text", "w300 h20", "Key Bind (single letter):")
    settingsGui.Add("Edit", "w150 h25 vBindKeyInput", bindKey)
    
    settingsGui.Add("Text", "w300 h20", "Click Count During Delay:")
    settingsGui.Add("Edit", "w150 h25 vClickCountInput", clickCount)
    
    settingsGui.Add("Text", "w300 h20", "")
    settingsGui.Add("Button", "w100 h30 vResetBtn", "Reset Defaults").OnEvent("Click", ResetDurations)
    settingsGui.Add("Button", "w100 h30 vSaveBtn", "Save Settings").OnEvent("Click", SaveSettings)
    settingsGui.Add("Button", "w100 h30 vCloseBtn", "Close").OnEvent("Click", CloseSettings)
    
    settingsGui.Show("w380 h400")
}

SaveSettings(GuiObjOrEvent, Info)
{
    global settingsGui, holdDuration, delayBetweenCycles, bindKey, clickCount
    
    settingsGui.Submit(0)
    
    holdDuration := Integer(settingsGui["HoldDurationInput"].Value)
    delayBetweenCycles := Integer(settingsGui["DelayInput"].Value)
    bindKey := SubStr(settingsGui["BindKeyInput"].Value, 1, 1)
    clickCount := Integer(settingsGui["ClickCountInput"].Value)
    
    ; Save to file
    IniWrite(holdDuration, "sawah_settings.ini", "Configuration", "HoldDuration")
    IniWrite(delayBetweenCycles, "sawah_settings.ini", "Configuration", "Delay")
    IniWrite(bindKey, "sawah_settings.ini", "Configuration", "BindKey")
    IniWrite(clickCount, "sawah_settings.ini", "Configuration", "ClickCount")
    
    MsgBox("Settings saved successfully!", "Sawah")
    settingsGui.Destroy()
    settingsGui := 0
}

LoadSettings()
{
    global holdDuration, delayBetweenCycles, bindKey, clickCount
    
    if (FileExist("sawah_settings.ini"))
    {
        holdDuration := IniRead("sawah_settings.ini", "Configuration", "HoldDuration", 4000)
        delayBetweenCycles := IniRead("sawah_settings.ini", "Configuration", "Delay", 500)
        bindKey := IniRead("sawah_settings.ini", "Configuration", "BindKey", "e")
        clickCount := IniRead("sawah_settings.ini", "Configuration", "ClickCount", 2)
    }
}

ResetDurations(GuiObjOrEvent, Info)
{
    global holdDuration, delayBetweenCycles, settingsGui
    ; revert to defaults
    holdDuration := 4000
    delayBetweenCycles := 500
    if (settingsGui && IsObject(settingsGui))
    {
        settingsGui["HoldDurationInput"].Value := holdDuration
        settingsGui["DelayInput"].Value := delayBetweenCycles
    }
    MsgBox("Hold duration and delay have been reset to defaults.", "Sawah")
}

CloseSettings(GuiObjOrEvent, Info)
{
    global settingsGui
    if (settingsGui && IsObject(settingsGui))
    {
        try
            settingsGui.Destroy()
        settingsGui := 0
    }
}

; ========================================
; MAIN CYCLE FUNCTION
; ========================================
SetTimer(MainCycle, 50)

MainCycle()
{
    global cycling, holdDuration, delayBetweenCycles, bindKey, cycleProgress, currentPhase, cycleCount, clickCount
    
    static cycleTimer := 0
    static keyPressed := false
    static clicksDone := false
    
    if (!cycling)
    {
        if (keyPressed)
        {
            Send("{" . bindKey . " up}")
            keyPressed := false
        }
        cycleTimer := 0
        cycleProgress := 0
        currentPhase := "idle"
        clicksDone := false
        return
    }
    
    cycleTimer += 50
    cycleProgress := cycleTimer
    
    ; Press key at start
    if (cycleTimer == 50 && !keyPressed)
    {
        Send("{" . bindKey . " down}")
        keyPressed := true
        currentPhase := "pressing " . bindKey
        cycleCount++
        clicksDone := false
    }
    
    ; Release key after hold duration
    if (cycleTimer >= holdDuration && keyPressed)
    {
        Send("{" . bindKey . " up}")
        keyPressed := false
        currentPhase := "delay"
    }
    
    ; Perform clicks during delay (right after release)
    if (cycleTimer >= holdDuration && cycleTimer < (holdDuration + 100) && !clicksDone)
    {
        Loop clickCount
        {
            MouseClick("Left")
            Sleep(50)
        }
        clicksDone := true
    }
    
    ; Reset cycle after hold + delay
    if (cycleTimer >= (holdDuration + delayBetweenCycles))
    {
        cycleTimer := 0
        currentPhase := "pressing " . bindKey
    }
}
