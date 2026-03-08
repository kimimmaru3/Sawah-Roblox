# Hotkey Cycle Program (AutoHotkey v2)

An AutoHotkey v2 script that allows you to control keyboard automation using hotkeys.

## Features
- **F3**: Toggle cycling ON/OFF
- **F4**: Exit the program
- **Active Cycle**: Holds button 'E' for 4 seconds, releases, then repeats continuously

## Requirements
- AutoHotkey v2 installed: https://www.autohotkey.com/v2/

## Installation

1. Download and install AutoHotkey v2 from https://www.autohotkey.com/v2/

2. Place the `hotkey_cycle.ahk` file in your desired location

## Usage

1. Run `hotkey_cycle.ahk` by double-clicking it

2. A message box will appear confirming the script is ready

3. Control the program:
   - Press **F3** to start the cycle
   - Press **F3** again to stop the cycle
   - Press **F4** to exit the program

## How It Works
- When cycling is active, the 'E' key will be pressed and held for 4 seconds
- The key is then released, and after a brief pause (500ms), the cycle repeats
- The program runs continuously listening for F3 and F4 key presses
- A tooltip displays when you toggle the cycling state

## Troubleshooting
- Make sure AutoHotkey v2 is installed (not v1)
- Run the script with administrator privileges if hotkeys aren't detected
- Ensure the application you want to control is in focus
- You can close the program anytime by pressing F4

## Notes
- This works with any application that accepts keyboard input
- Designed for Windows systems
- Always ensure you have permission to automate keyboard input in your target application
