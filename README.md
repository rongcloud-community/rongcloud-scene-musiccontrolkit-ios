> [!WARNING]
> ⚠️ **暂停维护说明**
>
> 该工程已不再维护。

<h1 align="center"> 场景化音乐播放组件 </h>
<p align="center">
<a href="https://github.com/rongcloud-community/rongcloud-scene-musiccontrolkit-ios">
<img src="https://img.shields.io/cocoapods/v/RCMusicControlKit.svg?style=flat">
</a>
<a href="https://github.com/rongcloud-community/rongcloud-scene-musiccontrolkit-ios">
<img src="https://img.shields.io/cocoapods/l/RCSceneRadioRoom.svg?style=flat">
</a>
<a href="https://github.com/rongcloud-community/rongcloud-scene-musiccontrolkit-ios">
<img src="https://img.shields.io/cocoapods/p/RCSceneRadioRoom.svg?style=flat">
</a>
<a href="https://github.com/rongcloud-community/rongcloud-scene-musiccontrolkit-ios">
<img src="https://img.shields.io/badge/in-objc2-orange">
</a>



## 简介

本仓库是融云场景化团队开源的音乐播放组件，组件内封装了音乐列表、收藏列表、混音控制、音效播放等功能。 通过实现相应的接口协议，可以方便快捷的适配各类音乐库和播放器。

## 集成

### 使用 CocoaPods

1. 终端 cd 至项目根目录
2. 执行 pod init 
3. 执行 open -e Podfile
4. 添加导入配置 pod 'RCMusicControlKit'
5. 执行 pod install
6. 双击打开 .xcworkspace

## 功能

| 模块     | 简介                                                         | 示图                                                         |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 音乐列表 | 展示从曲库获取的音乐和歌曲，支持歌单分类、音乐和歌曲的收藏。 | <img src="https://tva1.sinaimg.cn/large/e6c9d24ely1h1aef8nyqrj20800hcaap.jpg" style="zoom:50%;" /> |
| 收藏列表 | 展示收藏的音乐和歌曲，支持删除收藏、调整顺序。               | <img src="https://tva1.sinaimg.cn/large/e6c9d24ely1h1aefd7nmyj20800hcwev.jpg" style="zoom:50%;" /> |
| 音效控制 | 支持本地音量调整，远端音量调整，麦克风音量，耳返功能开关。   | <img src="https://tva1.sinaimg.cn/large/e6c9d24ely1h1aefiebhvj20800hcq3b.jpg" style="zoom:50%;" /> |
| 播放音效 | 支持播放入场、鼓掌等音效。                                   |                                                              |

## 使用

- 分别实现遵循 RCMusicPlayer、RCMusicDataSource、RCMusicDelegate 协议的实现类

  ![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1af8u0zqjj21da0d6q6n.jpg)

- 将上一步中协议的实现类对象 player、dataSource、delegate 设置到 RCMusicEngine 中

  - player 实现播放器的相关功能
  - dataSource 提供列表展示所需要的数据
  - delegate 提供列表收藏、删除收藏、调整顺序相关的操作调用

  ```objc
  RCMusicEngine.shareInstance.player = player
  RCMusicEngine.shareInstance.dataSource = dataSource
  RCMusicEngine.shareInstance.delegate = delegate
  ```

  <img src="https://tva1.sinaimg.cn/large/e6c9d24ely1h1aea8lubsj21620fb40m.jpg" style="zoom:50%;" />

- 在需要显示音乐组件的页面中调用如下方法

```objc
[RCMusicEngine.shareInstance showInViewController:self completion:^{
     NSLog("do something");
}];
```



## 其他

如有任何疑问请提交 issue
