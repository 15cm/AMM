# AMM ![Travis CI](https://travis-ci.org/15cm/AMM.svg?branch=master)
Aria2 Menubar Monitor, a tool to help with monitoring Aria2 Status on the macOS menubar.

[中文说明](./README_zh.md)

# Features
- Display status of Aria2 server on menubar using Aria2 RPC.
- Multiple Aria2 servers support. Per-server configuration.
- ws/wss(including self-signed certificate) support
- Notifications of task events
- Dark mode
- Control mode for task management
- Association with magnet link

# Screenshots
## Light Mode
![Screenshot Light](./screenshots/screenshot.png)

## Dark Mode
![Screenshot Dark](./screenshots/screenshot-dark.png)

# Prerequisites
OS X 10.10+ or macOS 10.12.x

# Download
See [Releases](https://github.com/15cm/AMM/releases)

# Test and Build Environment
- macOS Sierra 10.13.2
- Xcode 9.2
- Swift 4.0.3
- carthage 0.27.0

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
