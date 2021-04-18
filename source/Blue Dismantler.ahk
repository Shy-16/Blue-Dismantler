/*
    Filename:        Blue Dismantler.ahk
    Author:          Pedro Torres
    Version:         0.3.4
    Release Date:    4/18/2021
    Description:
    This script allows users to automatically dismantle blue rarity item drops in Destiny 2 while in their
    character or postmaster menus.
    
    Copyright:
    Copyright (C) 2021 Pedro Torres
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    Contact:
    https://pedrotorresgames.com
    pedro_t16@outlook.com
    
    Disclaimer:
    Destiny and Destiny 2 are property of Bungie, Inc.. This software was not produced in collaboration
    with Bungie, Inc. and is not endorsed by Bungie, Inc. in any way.
    This program is a work in progress that is being actively developed. New versions will be released at
    the GitHub repository for this project. This script does NOT check for updates and will not alert
    you to new versions, so follow the developer for updates and new releases.
*/

;----------------------------NOTES FROM THE AUTHOR----------------------------
; Moving the cursor around the screen moves UI elements subtly.
; Destiny 2 being in Window Mode "Windowed" causes the resolution of the window to be different than the Resolution in the settings.
; WinGetPos returns a width that is 16 pixels longer than expected when in windowed mode.
; It also returns the FULL size of the window including the title bar at the top which is always 39 extra pixels tall when in windowed mode.
; Color comparisons should be done in RGB format using Hexadecimal numbers.
;----------------------------------------------------------------------------

;--------------------------------------------------
; SCRIPT SETTINGS AND DEPENDANCIES
;--------------------------------------------------
#NoEnv                                       ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn                                        ; Enable warnings to assist with detecting common errors
SendMode Input                               ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%                  ; Set the working directory
configPath := A_ScriptDir "\config\config.ini"

; Checks for dependancies and create them if they're not found
FileInstall, config\config.ini, configPath    ; Used for building executable
FileInstall, README.txt, %A_ScriptDir%

if !FileExist(configPath)
{
    FileCreateDir, %A_ScriptDir%\config
    FileAppend,
    (
    [Options]
    # hunter, titan, warlock
    CLASS=hunter
    
    # 0, 1
    WINDOWED=0
    
    # check the readme
    INVENTORY_SHORTCUT=^I
    POSTMASTER_SHORTCUT=^O
    STOP_DISMANTLING=^X
    TERMINATE_SCRIPT=^Q
    
    # 0, deut, pro, tri
    COLORBLIND_MODE=0
    
    # 1, 0
    DEBUG_MODE=0
    )
}

if !FileExist("README.md")
{
    githubReadMeLink := "https://raw.githubusercontent.com/Shy-16/Dismantler/main/README.md"
    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WebRequest.Open("GET", githubReadMeLink)
    WebRequest.Send()
    Response := WebRequest.ResponseText
    FileAppend, %Response%, %A_ScriptDir%\README.md
}

;--------------------------------------------------
; PROPERTIES
;--------------------------------------------------
;=====Class Specific Variables=====
class := {}
hunterArmorOffsets := {helmet: [1.15, 1], arms: [-1, 1], chest: [-1, 1], legs: [1, -1], classItem: [-1, 1]}
titanArmorOffsets := {helmet: [-1, 1], arms: [1, 1], chest: [-1, 1], legs: [1, 0], classItem: [-1.1, .4]}
warlockArmorOffsets := {helmet: [-1, 1], arms: [1, 1], chest: [1.16, 1], legs: [1, 0], classItem: [1, 1]}

;=====Coloblind Variables=====
defaultBlue := 0x5076A4
deutBlue := 0x718BB5
proBlue := 0x7797BE
triBlue := 0x404EA3

;=====Screen Coordinates and UI sizes=====
; Get game resolution and store width/height
WinActivate, Destiny 2
WinGetPos, , , screenWidth, screenHeight, A, , ,

; Item box size
boxSize := (screenWidth * .05)

; X-Coordinates of the weapon column in screen space
weaponsXCoord := (screenWidth * .275)
armorXCoord := (screenWidth * .725)

; Y-Coordinates of the armor column in screen space
helmetYCoord := (screenHeight * .25)
armsYCoord := helmetYCoord + (screenHeight * .115)
chestYCoord := armsYCoord + (screenHeight * .115)
legsYCoord := chestYCoord + (screenHeight * .115)
classYCoord := legsYCoord + (screenHeight * .115)

; Offset used when inspecting an item icon (pixels in screen space)
cornerOffset := Round(boxSize * .36458)

;=====Dismantling Settings=====
; Duration button is held to dismantle in miliseconds
dismantleHoldDuration := 1050


;--------------------------------------------------
; Initializations
;--------------------------------------------------
;=====Config Settings=====
IniRead, className, %configPath%, Options, CLASS
class.name := className

if !class
    MsgBox error: class not defined
else
{
    switch class.name
    {
        case "hunter":
        class.armorOffsets := hunterArmorOffsets
        
        case "titan":
        class.armorOffsets := titanArmorOffsets
        
        default:
        class.armorOffsets := warlockArmorOffsets
    }
}

windowed := false
IniRead, windowed, %configPath%, Options, WINDOWED, 0

colorBlindMode := 0
IniRead, colorBlindMode, %configPath%, Options, COLORBLIND_MODE, 0

debugMode := 0
IniRead, debugMode, %configPath%, Options, DEBUG_MODE, 0

; Any custom shortcut codes must be sanitized of operators and other special characters
bannedCharacters := [";", "@", "$", "%", "&", "*", "<", ">", ",", ".", "/", "\", "{", "}", "|", "``", "~", "UP"]

inventoryShortcut := ^I
postmasterShortcut := ^O
stopDismantling := ^X
terminateScript := ^Q
IniRead, tempInvShortcut, %configPath%, Options, INVENTORY_SHORTCUT, ^I
IniRead, tempPostShortcut, %configPath%, Options, POSTMASTER_SHORTCUT, ^O
IniRead, tempStopDismantle, %configPath%, Options, STOP_DISMANTLING, ^X
IniRead, tempTerminateScript, %configPath%, Options, TERMINATE_SCRIPT, ^Q

SanitizeInput(tempInvShortcut)
SanitizeInput(tempPostShortcut)
SanitizeInput(tempStopDismantle)
SanitizeInput(tempTerminateScript)

if tempInvShortcut != "ERROR"
    inventoryShortcut := tempInvShortcut
if tempPostShortcut != "ERROR"
    postmasterShortcut := tempPostShortcut
if tempStopDismantle != "ERROR"
    stopDismantling := tempStopDismantle
if tempTerminateScript != "ERROR"
    terminateScript := tempTerminateScript

Hotkey, %inventoryShortcut%, Inventory_Dismantle, On
Hotkey, %postmasterShortcut%, Postmaster_Dismantle, On
Hotkey, %stopDismantling%, Stop_Dismantling, On
Hotkey, %terminateScript%, Terminate_Script, On

return


;--------------------------------------------------
;                DEBUG
;--------------------------------------------------
^Y::
if debugMode
{
    testColor := 0x000000
    x := 0
    y := 0
    subMenuIndex := 4
    xSubMenuOffset := 0
    ySubMenuOffset := 0
    GetEquipSlotLocation(false, "class", x, y)
    GetSubMenuOffsets(subMenuIndex, xSubMenuOffset, ySubMenuOffset)
    
    finalX := Round((x + xSubMenuOffset) + (cornerOffset * -1.1))
    finalY := Round((y + ySubMenuOffset) + (cornerOffset * .4))
    
    parallaxCompensation := GetHorParallaxOffset(finalX)
    ;MsgBox % finalX
    
    if (finalX <= (screenWidth / 2))
        finalX += parallaxCompensation
    else
        finalX -= parallaxCompensation
    
    MouseMove, x, y, 0
    Sleep, 150
    PixelGetColor, testColor, finalX, finalY, RGB
    MouseMove, finalX, finalY, 0
    Clipboard := testColor
    MsgBox % "Test 1: " . TestForBlue(testColor)
    
    if !TestForBlue(testColor)
    {
        finalX := Round((x + xSubMenuOffset) + (cornerOffset * 1))
        finalY := Round((y + ySubMenuOffset) + (cornerOffset * 1))
        
        parallaxCompensation := GetHorParallaxOffset(finalX)
        
        if (finalX <= (screenWidth / 2))
            finalX += parallaxCompensation
        else
            finalX -= parallaxCompensation
        
        MouseMove, x, y, 0
        Sleep, 150
        PixelGetColor, testColor, finalX, finalY, RGB
        MouseMove, finalX, finalY, 0
        Clipboard := testColor
        MsgBox % "Test 2: " . TestForBlue(testColor)
    }
}
return

;--------------------------------------------------
; MAIN
;--------------------------------------------------
; Many of the iterations through the character menu in this script could be done more concisely
; by employing the use of two enums for WeaponTypes and ArmorTypes.
; Since this script is specially designed to do one thing and on thing only, I did not do this, though I probably should (and will in the future).
#IfWinActive, Destiny 2
Inventory_Dismantle:
MouseMove, (screenWidth / 2), (screenHeight / 2)

if !class
{
    MsgBox error
    return
}

; ---------- Weapon Sub Menus ----------
; Kinetic Weapons
MouseMove, weaponsXCoord, armsYCoord, 0
Sleep, 150
PruneSubMenu(true, "arms", 1, -1)

; Energy Weapons
MouseMove, weaponsXCoord, chestYCoord, 0
Sleep, 150
PruneSubMenu(true, "chest", 1, 1)

; Power Weapons
MouseMove, weaponsXCoord, legsYCoord, 0
Sleep, 150
PruneSubMenu(true, "legs", 1, 1)

; ---------- Armor Sub Menus ----------
; Helmets
MouseMove, armorXCoord, helmetYCoord, 0
Sleep, 150
PruneSubMenu(false, "helmet", class.armorOffsets.helmet[1], class.armorOffsets.helmet[2])

; Arms
MouseMove, armorXCoord, armsYcoord, 0
Sleep, 150
PruneSubMenu(false, "arms", class.armorOffsets.arms[1], class.armorOffsets.arms[2])

; Chest
MouseMove, armorXCoord, chestYCoord, 0
Sleep, 150
PruneSubMenu(false, "chest", class.armorOffsets.chest[1], class.armorOffsets.chest[2])

; Legs
MouseMove, armorXCoord, legsYCoord, 0
Sleep, 150
PruneSubMenu(false, "legs", class.armorOffsets.legs[1], class.armorOffsets.legs[2])

; Class
MouseMove, armorXCoord, classYCoord, 0
Sleep, 150
if class.name == "titan"
    PruneSubMenu(false, "class", class.armorOffsets.classItem[1], class.armorOffsets.classItem[2], true)
else
    PruneSubMenu(false, "class", class.armorOffsets.classItem[1], class.armorOffsets.classItem[2])

MouseMove, (screenWidth / 2), (screenHeight / 2)
return
; ---------- END ----------


;#IfWinActive, Destiny 2
Postmaster_Dismantle:
MsgBox,
(
Postmaster dismantling is not available in this version of this script.
Please check the github page for updates.
)
return


Stop_Dismantling:
; Critical
MsgBox, 0x1034, ,
(
Dismantling was stopped; did you mean to pause the script?
Choose YES to restart the script
Choose NO to continue dismantling
)
IfMsgBox, Yes
{
    Reload
    Sleep, 1000
    MsgBox % "ERROR: script could not be restarted properly"
    ExitApp
}
IfMsgBox, No
{
    return
}
return

#IfWinActive
Terminate_Script:
Send {f up}
ExitApp

;--------------------------------------------------
; METHODS
;--------------------------------------------------
; This function asks for a **subMenuIndex**
; This would mean the subMenu item in the top-right-most box (for weapons) or top-left-most box (for armor) would be index 0.
; The rest count in the same direction as the game does; top to bottom, near to far from the currently equipped item
; If subMenuOffset is -1 (the default), the function inspects the currently equipped item
InspectPixel(isWeapon, rowName, horOffsetSign, vertOffsetSign, subMenuIndex := -1, secondCheck := false)
{
    global
    
    ; ----- local variables -----
    local pixelColor             ; The return value for the pixel being inspected
    local xCoord := 0            ; The x-coordinate of the item box in screen space
    local yCoord := 0            ; The y-coordinate of the item box in screen space
    local xSubMenuOffset := 0    ; The x-offset applied to inspect item boxes in a sub menu
    local ySubMenuOffset := 0    ; The y-offset applied to inspect item boxes in a sub menu
    
    ; ----- functionality -----
    GetEquipSlotLocation(isWeapon, rowName, xCoord, yCoord)
    
    GetSubMenuOffsets(subMenuIndex, xSubMenuOffset, ySubMenuOffset)
    if isWeapon
        xSubMenuOffset *= -1
    
    finalXCoord := Round((xCoord + xSubMenuOffset) + (cornerOffset * horOffsetSign))
    finalYCoord := Round((yCoord + ySubMenuOffset) + (cornerOffset * vertOffsetSign))
    parallaxOffset := GetHorParallaxOffset(finalXCoord)
    
    if (finalXCoord <= (screenWidth / 2))
        finalXCoord += parallaxOffset
    else
        finalXCoord -= parallaxOffset
    
    if !secondCheck
        PixelGetColor, pixelColor, finalXCoord, finalYCoord, RGB
    else
    {
        finalXCoord := Round((xCoord + xSubMenuOffset) + (cornerOffset * horOffsetSign))
        finalYCoord := Round((yCoord + ySubMenuOffset) + (cornerOffset * vertOffsetSign))
        parallaxOffset := GetHorParallaxOffset(finalXCoord)
        
        if (finalXCoord <= (screenWidth / 2))
            finalXCoord += parallaxOffset
        else
            finalXCoord -= parallaxOffset
        
        PixelGetColor, pixelColor, finalXCoord, finalYCoord, RGB
    }
    
    ;MouseMove, (xCoord + xSubMenuOffset) + (cornerOffset * horOffsetSign), (yCoord + ySubMenuOffset) + (cornerOffset * vertOffsetSign), 0
    ;Sleep, 100
    return pixelColor
}

; This function asks for a **subMenuIndex**
; This would mean the subMenu item in the top-right-most box (for weapons) or top-left-most box (for armor) would be index 0.
; The rest count in the same direction as the game does; top to bottom, near to far from the currently equipped item
; If subMenuOffset is -1 (the default), the function inspects the currently equipped item
Dismantle(isWeapon, rowName, subMenuIndex)
{
    global
    
    ; ----- local variables -----
    local xCoord := 0            ; The x-coordinate of the item box in screen space
    local yCoord := 0            ; The y-coordinate of the item box in screen space
    local xSubMenuOffset := 0    ; The x-offset applied to inspect item boxes in a sub menu
    local ySubMenuOffset := 0    ; The y-offset applied to inspect item boxes in a sub menu
    
    ; ----- functionality -----    
    GetEquipSlotLocation(isWeapon, rowName, xCoord, yCoord)
    
    GetSubMenuOffsets(subMenuIndex, xSubMenuOffset, ySubMenuOffset)
    if isWeapon
        xSubMenuOffset *= -1
    
    MouseMove, xCoord + xSubMenuOffset, yCoord + ySubMenuOffset, 0
    Sleep, 200
    Send {f down}
    Sleep, dismantleHoldDuration
    Send {f up}
    MouseMove, xCoord, yCoord, 0
}

; Iterates through all submenus and inspects them for blues dismantling any that it finds.
; If secondCheck is true, a secondary check will be done using secondary offsetSigns.
; If either the primary or secondary check return true, the item is dismantled.
; This is especially useful for items whose icons sometimes cover areas of the background that are used for inspection
PruneSubMenu(isWeapon, rowName, horOffsetSign, vertOffsetSign, secondCheck := false, secondHorSign := 1, secondVertSign := 1)
{
    global
    
    local xCoord := 0
    local yCoord := 0
    GetEquipSlotLocation(isWeapon, rowName, xCoord, yCoord)
    
    local curItem := 0
    Loop, 9
    {
        curItem := 9 - A_Index
        MouseMove, xCoord, yCoord, 0
        Sleep, 150
        
        if TestForBlue(InspectPixel(isWeapon, rowName, horOffsetSign, vertOffsetSign, curItem))
            Dismantle(isWeapon, rowName, curItem)
        
        if secondCheck
        {
            if TestForBlue(InspectPixel(isWeapon, rowName, secondHorSign, secondVertSign, curItem, true))
                Dismantle(isWeapon, rowName, curItem)
        }
    }
}

; This lines up the coordinate variables with the equipped item row and column depending on isWeapon and rowName
GetEquipSlotLocation(isWeapon, rowName, ByRef xCoord, ByRef yCoord)
{
    global
    
    if isWeapon
        xCoord := weaponsXCoord
    else
        xCoord := armorXCoord
    
    switch rowName
    {
        case "helmet":
        yCoord := helmetYCoord
        
        case "arms":
        yCoord := armsYCoord
        
        case "chest":
        yCoord := chestYCoord
        
        case "legs":
        yCoord := legsYCoord
        
        case "class":
        yCoord := classYCoord
    }
}

; Sets the x and y subMenuOffset given a subMenuIndex
GetSubMenuOffsets(subMenuIndex, ByRef xSubMenuOffset, ByRef ySubMenuOffset)
{
    global
    
    if (subMenuIndex != -1)
    {
        switch Mod(subMenuIndex, 3)
        {
            case 0:
            xSubMenuOffset := Round(screenWidth * .059896) ; 115 in 1920x1080
            
            case 1:
            xSubMenuOffset := Round(screenWidth * .113542) ; 218 in 1920x1080
            
            case 2:
            xSubMenuOffset := Round(screenWidth * .166666) ; 315 in 1920x1080
        }
    }
    
    if (subMenuIndex < 3)
        ySubMenuOffset := 0
    else if (subMenuIndex < 6)
        ySubMenuOffset := Round(screenHeight * .094444)
    else
        ySubMenuOffset := Round(screenHeight * .188889)
}

; Returns true if the provided testColor is close enough to the expected color of the background given the current colorblindMode
TestForBlue(testColor)
{
    global
    
    ; Error tolerance before a value is considered NOT blue
    local tolerance := 600
    local targetRed := 0
    local targetGreen := 0
    local targetBlue := 0
    local red := 0
    local green := 0
    local blue := 0
    local diffRed := 0
    local diffGreen := 0
    local diffBlue := 0
    local error := 0
    
    ; The values of each color channel that produces the blue rarity background color
    switch colorBlindMode
    {
        case 0:
        {
            targetRed := (defaultBlue & 0xff0000) >> 16
            targetGreen := (defaultBlue & 0x00ff00) >> 8
            targetBlue := (defaultBlue & 0x0000ff) >> 0
        }
        case "deut":
        {
            targetRed := (deutBlue & 0xff0000) >> 16
            targetGreen := (deutBlue & 0x00ff00) >> 8
            targetBlue := (deutBlue & 0x0000ff) >> 0
        }
        case "pro":
        {
            targetRed := (proBlue & 0xff0000) >> 16
            targetGreen := (proBlue & 0x00ff00) >> 8
            targetBlue := (proBlue & 0x0000ff) >> 0
        }
        case "tri":
        {
            targetRed := (triBlue & 0xff0000) >> 16
            targetGreen := (triBlue & 0x00ff00) >> 8
            targetBlue := (triBlue & 0x0000ff) >> 0
        }
    }
    
    ; Store each channel of testColor seperately
    ; Assumes RGB color order
    red   := (testColor & 0xff0000) >> 16
    green := (testColor & 0x00ff00) >>  8
    blue  := (testColor & 0x0000ff) >>  0
    
    diffRed   := abs(targetRed - red)
    diffBlue  := abs(targetBlue - blue)
    diffGreen := abs(targetgreen - green)
    
    error := (diffRed * diffRed) + (diffBlue * diffBlue) + (diffGreen * diffGreen)
    if (error < tolerance)
        return true
    else
        return false
}

; Sanitizes variables retrieved from config.ini using the bannedCharacters list
SanitizeInput(ByRef shortcutVariable)
{
    global
    For index, character in bannedCharacters
    {
        if !InStr(shortcutVariable, character)
            Continue
        else
        {
            shortcutVariable := "ERROR"
            return
        }
    }
}

; Returns an offset used to account for the mouse's position on the screen in the character menu.
; Moving the mouse around in the character menu causes UI elements to parallax around subtly.
; This function takes in an x-coordiante and gives an offset that should be applied to the mouse to account for this effect.
; Vertical parallax is not significant enough in the currently supported resolution to knock the inspectPixel function out of whack.
GetHorParallaxOffset(xCoord)
{
    global
    
    if (windowed)
        return parallaxCompensation := Round((Abs(xCoord - ((screenWidth - 16) / 2)) / (screenWidth * .0260417)) / 2)
    else
        return parallaxCompensation := Round((Abs(xCoord - (screenWidth / 2)) / (screenWidth * .0260417)) / 2)
    
}
