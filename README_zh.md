# AMM ![Travis CI](https://travis-ci.org/15cm/AMM.svg?branch=master)
Aria2 Menubar Monitor,  在 macOS 菜单栏上监控 Aria2 的工具。

# 功能
- 通过 Aria2 RPC 接口，在 menubar 中显示 Aria2 状态
- 多服务器、单服务器配置支持
- ws/wss(包括自签证书)支持
- 任务事件通知
- 暗色主题
- 用于管理任务的控制模式
- 磁力链接关联

# 截图
## 亮色主题
![Screenshot Light](./screenshots/screenshot.png)

## 暗色主题
![Screenshot Dark](./screenshots/screenshot-dark.png)

# 运行环境
OS X 10.10+ or macOS 10.12.x

# 下载
见 [Release](https://github.com/15cm/AMM/releases)

# 测试、构建环境
- macOS Sierra 10.13.2
- Xcode 9.2
- Swift 4.0.3
- carthage 0.27.0

# 构建流程
``` sh
git clone https://github.com/15cm/AMM.git
cd AMM
carthage update --platform mac --no-use-binaries
open AMM.xcodeproj
```

然后在 **Xcode** 中按 Cmd-b 构建 **AMM**

# 感谢
- [aria2](https://github.com/aria2/aria2) 
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
- [Starscream](https://github.com/daltoniam/Starscream)
- [SwiftyUserDefaults](https://github.com/radex/SwiftyUserDefaults)
- [Maria](https://github.com/ShinCurry/Maria) （部分实现思路参考）

# 许可证书
GPL 3.0
