# AMM
Aria2 Menubar Monitor, a tool to help with monitoring Aria2 Status on macOS menubar.

[中文说明](./README_zh.md)

# Features
- Fetch status of Arai2 Server using Aria2 RPC(via websocket) and display it.
- Multiple Aria2 servers support. Refresh interval of global status and tasks can be configured for each server.

# Screenshots
![Screenshots](./screenshot.png)

# Remark
## About Values in Preferences
In current version, all value in "AMM Preferences" will not be validated.(Validation will be added in the future)
It's your responsibility to take care of your settings, especially the refresh intervals, values of which are suggested to be no less than 0.5(s).

## About Preferences Changes
It happens sometimes(especially when refresh intervals being set too short) that every confirm of a preferences change(when you click "OK" or "Cancel") causes memory leak. Therefore please restart AMM if you make preferences changes several times and find AMM take up too much resources.

# Prerequisite
OS X 10.10+ or macOS 10.12.x

# Download
See [Release](https://github.com/15cm/AMM/releases)

# Test and Build Environment
- macOS Sierra 10.12.3 (16D32)
- Xcode 8.2.1 (8C1002)
- Swift 3.0.2
- carthage 0.18.1

# Thanks
- [aria2](https://github.com/aria2/aria2) 
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
- [Starscream](https://github.com/daltoniam/Starscream)
- [Maria](https://github.com/ShinCurry/Maria) (Implementation partial reference)

# License
GPL 3.0
