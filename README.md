# SHY'S DESTINY 2 BLUE DISMANTLER

### Intro
Most avid fans of Destiny 2 will know that once your character reaches a certain light level, blue rarity items cease to have value other than being a source of legendary shards. However, consistently dismantling blues gets tiresome after a while. To alleviate this problem, I present to you, the Blue Dismantler!  

This lightweight script allows Destiny 2 players to automatically dismantle any and all blues on their character or in their postmaster through a single, customizable keyboard shortcut. Before you can cleanse yourself of blues forever, though, please read the following information about how to use and customize this script.  

### Copyright
*Copyright (C) 2021 Pedro Torres*  
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.   You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.

Contact:  
<https://pedrotorresgames.com>.  
<pedro_t16@outlook.com>.  

### Disclaimer
Destiny and Destiny 2 are the property of Bungie, Inc.. This software was not produced in collaboration with Bungie, Inc. and is not endorsed by Bungie, Inc. in any way.  

This program is a work in progress and is being actively developed. New versions will be released at the GitHub [repository](https://github.com/Shy-16/Dismantler) for this project.  

This script does **not** check for updates and will not alert you when a new version is available, so follow the developer for updates and new releases.  

## How to Use
Launch Blue Dismantler.exe to start the script. The script should be running in the background. To check if this is the case, check your Windows system tray for a green icon with a "H" in it.  
While in your character menu, press CTRL+I (by default) and watch your blues disappear.  
Press CTRL+O (by default) to trigger dismantling in the postmaster.  
Press CTRL+X (by default) to stop the dismantling process once it has started.  
Press CTRL+Q to terminate the script.  

These shortcuts can be customized using the *config.ini* file found in the config folder in the *Blue Dismantler.exe* directory. If no such folder exists, simply run the executable once and a new folder and *.ini* file should be created in the same folder as the executable.  
Check the [Customization] section of this readme for more information.

### Limitations
The Blue Dismantler script dismantles **all** blues in your character menu or postmaster. It is designed to work when these menus are already open even though the dismantle functions can be triggered outside of those menus. If this happens accidentally, you can stop the script manually or close the script using the *STOP_DISMANTLING* and *TERMINATE_SCRIPT* shortcuts respectively.  
See the [How to Use] section of this readme for more details.  

The Dismantler does **not** dismantle blues that are currently equipped on your character.  
If you have any blues you want to keep safe, either equip them temporarily, lock them, or move them to your vault.  

The Dismantler must use the mouse to operate correctly. This means that when you trigger the script to dismantle, you cannot use the mouse. Moving the mouse even subtly can disrupt the process and cause blues to be missed or incompletely dismantled.

### Customization
The Blue Dismantler executable should come with an accompanying configuration file (named *config.ini*) that allows you to customize how the script works behind the scenes.  
This file can be found in the config folder that is distributed with the Blue Dismantler executable. If this folder doesn't exist, simply run the executable once and a new folder containing a default config file should be created for you. Before making any changes, though, remember to:  
* Close any isnstances of the script before making any modifications to the config file.  
* You must leave no spaces between the name of the setting you are changing, the "=" separating the name and the chosen setting, and the setting you choosing.  
  * Example: To change the *INVENTORY_SHORTCUT* setting to CTRL+D instead of the default CTRL+I, that line in the file must be written as "INVENTORY_SHORTCUT=^D". Check [INVENTORY_SHORTCUT] for a table of the codes used to represet modifier keys.

Below is a list of all of the things you can change in the *config.ini* file.  

***

#### INVENTORY_SHORTCUT
The shortcut keystroke used to trigger this script to dismantle blues while in the character menu.  
To change this setting, you must use one (or more) recognized key codes and write them *exactly* as they appear in the table below.  

* **Note:** If a key does not appear on the key codes chart and is **not** an alpha-numeric key (a-z ; 1-0), it is not a supported key.  

To combine more than one key in a custom keystroke, write them in one long string; do **not** separate key codes with spaces or any other character. The symbols for alpha-numeric keys do not require special coded characters; they can simply be entered as is.  
* **Note:** Numberpad keys only function when the Num function of your keyboard is toggled on.

| KEY CODES                        |
| :---          |:----:            |
| *Key Name*    | *Code*           |
| Number Pad    |Numbpad1-Numbpad0 |
| Function keys |F1-F24            |
| Control       |^                 |
| Shift         |+                 |
| Alt           |!                 |
| Windows key   |#                 |

| Default               |
| :---    | :---        |
| *Code*  | *Keystroke* |
| ^I      | CTRL+I      |

**Example:** To set your keyboard shortcut to Shift+Alt+A, you would write "*+!A*" (without the quotation marks).

* **Note:** If your keyboard does not support n-key rollover, you may run into a limit to how many keys you can include in your custom shortcut.

***

#### STOP_DISMANTLING  
The shortcut keystroke used to stop the script while it is in the process of dismantling items.  
To change this setting, you must use one of the recognized key codes and write them **Exactly** as they appear in the key code table found in [INVENTORY_SHORTCUT].  
* **Note:** Numberpad keys only function when the NumLock function of your keyboard is toggled on. Only the numeric numberpad keys are supported.  

| Default               |
| :---    | :---        |
| *Code*  | *Keystroke* |
| ^X      | CTRL+X      |

***

#### TERMINATE_SCRIPT  
The shortcut keystroke used to terminate the Blue Dismantler script.  
To change this setting, you must use one of the recognized key codes and write them **Exactly** as they appear in the key code table found in [INVENTORY_SHORTCUT].  
* **Note:** Numberpad keys only function when the NumLock function of your keyboard is toggled on. Only the numeric numberpad keys are supported.  

| Default               |
| :---    | :---        |
| *Code*  | *Keystroke* |
| ^Q      | CTRL+Q      |

***

### COLORBLIND_MODE  
Whether or not you are using a colorblind mode in game.  

| Options                                                                                  |
| :---           | :---                                                                    |
| Option string  | Description                                                             |
| 0              | Use this option when not using a colorblind mode in Destiny             |
| deut           | Use this option when using the Deuteranopia (red-green) colorblind mode |
| pro            | Use this option when using the Protanopia (red-green) colorblind mode   |
| tri            | Use this option when using the Tritanopia (yellow-blue) colorblind mode |

***

#### DEBUG_MODE  
This setting is for development purposes only and is not recommended for normal users.  

1 = Debug mode on  
0 = Debug mode off  

***

# CREDITS  
Created by:  
Pedro Torres  
*Copyright (C) 2021 Pedro Torres*  

*Created using AutoHotkey*
