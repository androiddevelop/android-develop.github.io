---
layout: post
title: 'Android导航栏隐藏与浮现(二)'
date: '2016-09-16'
header-img: "img/post-bg-android.jpg"
tags:
     - android
author: 'Codeboy'
---

在[Android导航栏隐藏与浮现(一)](/2015/10/22/android-navigation-bar-immerse/)中已经以 `Nexus5` 为例，`Android M` 为基础介绍了怎么实现底部导航栏的隐藏与浮现，本文将介绍怎么在设置(辅助功能)中加入控制该功能的开关。

<img src="/img/android-navigation-enhance.png" style="max-width:49.5%;  clear: both;
 display: block;
 margin:auto;">

上图可以看到，应用中加入了一个 `Enhance Navigation bar` 的选项，该功能开启后可以长点击任务键(Recent)时，导航栏隐藏；从下不向上滑时，导航栏展示。 关闭后即取消了该功能。下面看一下整体的操作步骤:

- 添加试图到相应布局
- 实现状态保存，控制逻辑
- 在导航栏的操作中判断开关状态
- 编译打包

## 添加试图

#### ① 添加中文资源名称

在 `Settings.apk` 中修改相应的资源文件即可，修改中可以参考系统设置中的 `Large text`, 步骤如下：

修改 `./packages/apps/Settings/res/values-zh-rCN/strings.xml`，添加资源名称：

```
<string name="accessibility_toggle_enhance_navigation_bar_preference_title">"增强导航栏功能"</string>
```

#### ② 添加英文资源名称

修改 `./packages/apps/Settings/res/values/strings.xml`，添加资源名称：

```
<string name="accessibility_toggle_enhance_navigation_bar_preference_title">Enhance navigation bar</string>
```

#### ③ 添加选择开关

修改 `./packages/apps/Settings/res/xml/accessibility_settings.xml`，添加开关：

```
<SwitchPreference
  android:key="toggle_enhance_navigation_bar_preference"
  android:title="@string/accessibility_toggle_enhance_navigation_bar_preference_title"
  android:persistent="false"/>
```

> 位置自己可以定义，文本放置在`Large text`功能下方。

## 控制逻辑


#### ① 添加开关字段

修改 `./frameworks/base/core/java/android/provider/Settings.java`, 添加字段:

```
public static final String ACCESSIBILITY_ENHANCE_NAVIGATION_BAR = "enhance_navigation_bar";
```

#### ② 添加默认开关

修改文件 `./frameworks/base/packages/SettingsProvider/res/values/defaults.xml`,添加默认开关:

```
<bool name="def_accessibility_enhance_navigation_bar">false</bool>
```

#### ③ 添加控制逻辑

修改文件 `./packages/apps/Settings/src/com/android/settings/accessibility/AccessibilitySettings.java`, 修改部分基本和 `Large text` 的相同，diff后的试图如下，也可以根据下面提供修改前和修改后的文件，可以使用 `diff` 工具对比查看。

[diff后的文件对比试图](/file/diff.html)

[AccessibilitySettings修改前](/file/AccessibilitySettings_before.java)     [AccessibilitySettings修改后](/file/AccessibilitySettings_after.java) 


## 读取状态，控制功能开关 

修改 `./frameworks/base/packages/SystemUI/src/com/android/systemui/statusbar/phone/PhoneStatusBar.java`,添加变量:

```
private boolean enhanceNavigationSwitch = false; //默认关闭
```
在recent键长点击处添加开关控制：

```
try {
//读取开关状态
    enhanceNavigationSwitch = Settings.Secure.getInt(mContext.getContentResolver(), android.provider.Settings.Secure.ACCESSIBILITY_ENHANCE_NAVIGATION_BAR) == 1;
} catch (Settings.SettingNotFoundException e) {
    e.printStackTrace();
}
//开关关闭不进行任何操作
if (!enhanceNavigationSwitch) {
    return true;
}
```
> 在`public boolean onLongClick(View view)`的开始部分，用于判断是否执行长点击隐藏导航栏 

## 编译打包

使用 `mmm` 命令针对涉及的模块进行打包；

使用 `make snod` 命令生成 `system.img`。


## 小结

两次的结合完整的解决了导航栏的隐藏与浮现，终于可以不用一直看着不搭配的导航栏了。下面是隐藏前后QQ音乐的截图:

<img src="/img/android-navigation-enhance-qqmusic-before.png" style="max-width:49.5%;display:inline-block;">
<img src="/img/android-navigation-enhance-qqmusic-after.png" style="max-width:49.5%;display:inline-block;">

刷机需谨慎！刷机需谨慎！刷机需谨慎！如若刷机请提前备份数据！

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
