# AMM ![Travis CI](https://travis-ci.org/15cm/AMM.svg?branch=master)
Aria2 Menubar Monitor, a tool to help with monitoring Aria2 Status on macOS menubar.

[中文说明](./README_zh.md)

# Features
- Fetch status of Aria2 Server using Aria2 RPC(via websocket) and display it.
- Multiple Aria2 servers support. Refresh interval of global status and tasks can be configured for each server.
- ws/wss(self-signed certificate included) support
- Dark Mode
- Control Mode for task management

# Screenshots
## Light Mode
![Screenshot Light](./screenshots/screenshot.png)

## Dark Mode
![Screenshot Dark](./screenshots/screenshot-dark.png)

# Prerequisite
OS X 10.10+ or macOS 10.12.x

# Download
See [Release](https://github.com/15cm/AMM/releases)

# Test and Build Environment
- macOS Sierra 10.12.5
- Xcode 8.3.3 (8E3004b)
- Swift 3.1
- carthage 0.23.0

# How to build
``` sh
git clone https://github.com/15cm/AMM.git
cd AMM
carthage update --platform mac --no-use-binaries
open AMM.xcodeproj
```

Then press Cmd-b in **Xcode** to build **AMM**

# Thanks
- [aria2](https://github.com/aria2/aria2) 
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
- [Starscream](https://github.com/daltoniam/Starscream)
- [SwiftyUserDefaults](https://github.com/radex/SwiftyUserDefaults)
- [Maria](https://github.com/ShinCurry/Maria) (Implementation partial reference)

# License
GPL 3.0
