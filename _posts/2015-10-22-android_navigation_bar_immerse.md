---
layout: post
title: 'Android导航栏隐藏与浮现'
date: '2015-10-22'
header-img: "img/post-bg-android.jpg"
tags:
     - android
author: 'Codeboy'
---


Android M已经发布了很久了，很多新的特性也非常的吸引人，比如Doze模式可以使导航时间更长，刷到nexus5上，体验了一下确实不错。但是导航栏(虚拟按键)一直存在，感觉不是特别的爽。今天我们就从android M(6.0)进行源码的修改,使其能够方便的进行导航栏的隐藏与恢复。

修改源码之前，看到了[http://blog.csdn.net/way_ping_li/article/details/45727335](http://blog.csdn.net/way_ping_li/article/details/45727335)地址的文章(记为文章A)，写的很好，但是写的有些省略，整体的操作也较为复杂，下面介绍下我的操作步骤:

	① 下载并编译源码
	② 长点击隐藏导航栏
	③ 上滑显示导航栏
	④ 编译部分修改代码，重新生成system.img

文章A的整体思路是在导航栏上添加了一个图标按钮，点击后隐藏导航栏，上滑显示导航栏。首先说一下隐藏导航栏，感觉官方的导航栏还是很完美的，所以不打算添加任何元素，这里对任务键(虚拟正方形按键)进行长点击操作进行修改；之后是上滑显示导航栏，文章A的思路是通过各种系统内的很多回调与消息的传递完成的，改动幅度蛮大的，自己尝试按照文章中的进行修改，需要对文章A中提到的部分进行修改外，还需对部分aidl以及与此相关的类进行修改等，比较的繁琐，当然最后确实是实现了上滑显示，本文将直接通过广播进行上滑操作的传递。
	
### 下载并编译源码

源码的下载编译可以参考google官方教程[https://source.android.com/source/downloading.html](https://source.android.com/source/downloading.html),本文编译的源码分支android-6.0.1_r50。

#### 这里需要注意几点：

- nexus5源码下载后需要下载[驱动](https://developers.google.com/android/nexus/drivers)，解压到根目录后执行，执行后产生vendor目录，之后编译代码

- 源码编译完成后，之后的framework的修改不用再次重新编译，只需使用mmm命令编译部分模块即可，最后使用**make snod**生成system.img,刷进手机即可。

- 修改framework后生成的system.img,在进行刷机时仅仅刷进system.img即可，**首次刷机尽量把userdata.img, boot.img都进行刷入**。

### 长点击隐藏导航栏
虚拟按键有3个，考虑到返回键一般有一定的作用，于是修改任务键(虚拟正方形按键)的长点击事件，使其在长点击后可以隐藏导航栏。

**./frameworks/base/packages/SystemUI/src/com/android/systemui/statusbar/phone/PhoneStatusBar.java**

	private void prepareNavigationBarView() {
        mNavigationBarView.reorient();

        mNavigationBarView.getRecentsButton().setOnClickListener(mRecentsClickListener);
        mNavigationBarView.getRecentsButton().setOnTouchListener(mRecentsPreloadOnTouchListener);
        mNavigationBarView.getRecentsButton().setLongClickable(true);
        //去除长点击操作
        //mNavigationBarView.getRecentsButton().setOnLongClickListener(mLongPressBackRecentsListener);
        mNavigationBarView.getBackButton().setLongClickable(true);
        mNavigationBarView.getBackButton().setOnLongClickListener(mLongPressBackRecentsListener);
        mNavigationBarView.getHomeButton().setOnTouchListener(mHomeActionListener);
        mNavigationBarView.getHomeButton().setOnLongClickListener(mLongPressHomeListener);
        //添加长点击操作，长点击进行导航栏的删除
        mNavigationBarView.getRecentsButton().setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View view) {
                mWindowManager.removeView(mNavigationBarView);
                mNavigationBarView = null ;
                //isNavigationShow用于记录当前导航栏状态，定义在PhoneStatusBar的全局变量中
				isNavigationShow = false ;
                Log.d("===>LYD", "remove navigation bar");

                return true;
            }
        });
        mAssistManager.onConfigurationChanged();
    }

此时进行长点击任务键将隐藏导航栏。
	

### 上滑显示导航栏
	
上滑显示导航栏借鉴了文章A中的一些技巧，在系统上滑时会回调./frameworks/base/services/core/java/com/android/server/policy/PhoneWindowManager.java的修改主要是实现onSwipeFromBottom(竖屏时)和onSwipeFromRight(横屏时)两个接口，在此两接口内发送广播。

**./frameworks/base/services/core/java/com/android/server/policy/PhoneWindowManager.java**

	 // monitor for system gestures
        mSystemGestures = new SystemGesturesPointerEventListener(context,
                new SystemGesturesPointerEventListener.Callbacks() {
                    @Override
                    public void onSwipeFromTop() {
                        if (mStatusBar != null) {
                            requestTransientBars(mStatusBar);
                        }    
                    }    
                    @Override
                    public void onSwipeFromBottom() {
                        if (mNavigationBar != null && mNavigationBarOnBottom) {
                            requestTransientBars(mNavigationBar);
                        }    
                        //开始发送广播
                        Intent intent = new Intent();
                        intent.setAction("LYD_SHOW_NAVIGATION_BAR");
                        mContext.sendBroadcast(intent);
                    }    
                    @Override
                    public void onSwipeFromRight() {
                        if (mNavigationBar != null && !mNavigationBarOnBottom) {
                            requestTransientBars(mNavigationBar);
                        }    
                        //开始发送广播
                        Intent intent = new Intent();
                        intent.setAction("LYD_SHOW_NAVIGATION_BAR");
                        mContext.sendBroadcast(intent);
                    }    
                    //省略后续代码

下面我们需要做的是在之前的PhoneStatusBar中对广播进行处理，将状态栏添加到windowManager中。

	 @Override
    public void start() {
    //省略代码，在此方法末尾动态注册广播监听器

        IntentFilter filter = new IntentFilter();
        filter.addAction("LYD_SHOW_NAVIGATION_BAR");
        mContext.registerReceiver(navBarBroadcastReceiver, filter);
    }

    private BroadcastReceiver navBarBroadcastReceiver = new LydShowNavigationBarBroadcast();

    private static boolean isNavigationShow = true ;

    //自定义广播
    class LydShowNavigationBarBroadcast extends  BroadcastReceiver{
        public LydShowNavigationBarBroadcast() {
            super();
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d("====>LYD", "receiver show navigation bar broadcast");

			//防止多次被添加
            if(isNavigationShow){
                return ;
            }

            showNavigationBar();
        }

        @Override
        public IBinder peekService(Context myContext, Intent service) {
            return super.peekService(myContext, service);
        }
    }  
    
    //展示导航栏
    public void showNavigationBar() {
        mNavigationBarView =(NavigationBarView) View.inflate(mContext, R.layout.navigation_bar, null);
        mNavigationBarView.setBar(this);
        prepareNavigationBarView();
        addNavigationBar();
        isNavigationShow = true;

        //防止在桌面时上拉出导航栏时，导航栏背景为黑色
        mNavigationBarView.setBackgroundColor(Color.TRANSPARENT);
        Log.d("===>LYD", "show navigation");
    }

代码到此就修改完了，下面我们只需要对相应模块进行编译就行了。

### 编译部分修改代码，重新生成system.img

- ①切换到源代码目录，运行 

		source build/envsetup.sh 
	
- ②编译PhoneWindowManager.java所在模块(core)

		mmm ./frameworks/base/services/core/
		mmm ./frameworks/base/services/
	
- ③编译PhoneStatusBar.java所在模块(SystemUI) 

		mmm frameworks/base/packages/SystemUI/
	
- ④生成system.img.
		 
		 make snod

- ⑤刷入system.img
	
		adb reboot bootloader
		fastboot flash system system.img
		
这样一个定制过导航栏的nexus5(hammerhead)系统已经制作完成了。

###  后记

由于笔者一般都是使用手机都是竖屏的，为了减少误操作，所以仅仅上滑时(swipeFromBottom)才显示导航栏，从右侧滑动(swipeFromRight)不触发操作，nexus5的朋友可以使用笔者打好的包[http://pan.baidu.com/s/1bnsM68R](http://pan.baidu.com/s/1bnsM68R)，原汁原味的系统，去除了语音播好与桌面的搜索栏(QuickSearchBox)。刷机有风险，大家需谨慎,本文仅仅是提供一种思想，刷机造成的问题与本文以及作者无关。

> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
