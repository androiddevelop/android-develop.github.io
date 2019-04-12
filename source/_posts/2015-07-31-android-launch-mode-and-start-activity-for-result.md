---
layout: post
title: 'Android LaunchMode and StartActivityForResult'
date: '2015-07-31'
header-img: "img/post-bg-android.jpg"
tags:
     - android
author: 'Codeboy'
---

android4.0+已经占据目前主流android系统版本了，在5.0版本发布后，android的LaunchMode与StartActivityForResult的关系发生了一些改变。

两个Activity，A和B，现在由A页面跳转到B页面，看一下LaunchMode与StartActivityForResult之间的关系：

### android5.0之前

|          | stand | singleTop | singleTask | singleInstance |
| -------- | ----- | --------- | ---------- | -------------- |
| stand |√|√|x|x|
| singleTop |√|√|x|x|
| singleTask |√|√|x|x|
| singleInstance |x|x|x|x|

### android5.0之后

|          | stand | singleTop | singleTask | singleInstance |
| -------- | ----- | --------- | ---------- | -------------- |
| stand |√|√|√|√|
| singleTop |√|√|√|√|
| singleTask |√|√|√|√|
| singleInstance |√|√|√|√|


### **为什么会是这样的呢？**

**ActivityStackSupervisor**类中的**startActivityUncheckedLocked**方法在5.0中进行了修改。在5.0之前，当启动一个Activity时，系统将首先检查Activity的launchMode，如果为A页面设置为**SingleInstance**或者B页面设置为**singleTask**或者**singleInstance**,则会在LaunchFlags中加入**FLAG_ACTIVITY_NEW_TASK**标志，而如果含有**FLAG_ACTIVITY_NEW_TASK**标志的话，**onActivityResult**将会立即接收到一个cancle的信息。

	if (sourceRecord == null) {
	    // This activity is not being started from another...  in this
	    // case we -always- start a new task.
	    if ((launchFlags&Intent.FLAG_ACTIVITY_NEW_TASK) == 0) {
	        Slog.w(TAG, "startActivity called from non-Activity context; forcing " +
	                "Intent.FLAG_ACTIVITY_NEW_TASK for: " + intent);
	        launchFlags |= Intent.FLAG_ACTIVITY_NEW_TASK;
	    }
	} else if (sourceRecord.launchMode == ActivityInfo.LAUNCH_SINGLE_INSTANCE) {
	    // The original activity who is starting us is running as a single
	    // instance...  this new activity it is starting must go on its
	    // own task.
	    launchFlags |= Intent.FLAG_ACTIVITY_NEW_TASK;
	} else if (r.launchMode == ActivityInfo.LAUNCH_SINGLE_INSTANCE
	        || r.launchMode == ActivityInfo.LAUNCH_SINGLE_TASK) {
	    // The activity being started is a single instance...  it always
	    // gets launched into its own task.
	    launchFlags |= Intent.FLAG_ACTIVITY_NEW_TASK;
	}
	// ......
	if (r.resultTo != null && (launchFlags&Intent.FLAG_ACTIVITY_NEW_TASK) != 0) {
	    // For whatever reason this activity is being launched into a new
	    // task...  yet the caller has requested a result back.  Well, that
	    // is pretty messed up, so instead immediately send back a cancel
	    // and let the new task continue launched as normal without a
	    // dependency on its originator.
	    Slog.w(TAG, "Activity is launching as a new task, so cancelling activity result.");
	    r.resultTo.task.stack.sendActivityResultLocked(-1,
	            r.resultTo, r.resultWho, r.requestCode,
	        Activity.RESULT_CANCELED, null);
	    r.resultTo = null;
	}

在5.0(含)之后的系统中，对此方法进行了修改：


	final boolean launchSingleTop = r.launchMode == ActivityInfo.LAUNCH_SINGLE_TOP;
	final boolean launchSingleInstance = r.launchMode == ActivityInfo.LAUNCH_SINGLE_INSTANCE;
	final boolean launchSingleTask = r.launchMode == ActivityInfo.LAUNCH_SINGLE_TASK;
	int launchFlags = intent.getFlags();
	if ((launchFlags & Intent.FLAG_ACTIVITY_NEW_DOCUMENT) != 0 &&
	        (launchSingleInstance || launchSingleTask)) {
	    // We have a conflict between the Intent and the Activity manifest, manifest wins.
	    Slog.i(TAG, "Ignoring FLAG_ACTIVITY_NEW_DOCUMENT, launchMode is " +
	            "\"singleInstance\" or \"singleTask\"");
	    launchFlags &=
	            ~(Intent.FLAG_ACTIVITY_NEW_DOCUMENT | Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
	} else {
	    switch (r.info.documentLaunchMode) {
	        case ActivityInfo.DOCUMENT_LAUNCH_NONE:
	            break;
	        case ActivityInfo.DOCUMENT_LAUNCH_INTO_EXISTING:
	            launchFlags |= Intent.FLAG_ACTIVITY_NEW_DOCUMENT;
	            break;
	        case ActivityInfo.DOCUMENT_LAUNCH_ALWAYS:
	            launchFlags |= Intent.FLAG_ACTIVITY_NEW_DOCUMENT;
	            break;
	        case ActivityInfo.DOCUMENT_LAUNCH_NEVER:
	            launchFlags &= ~Intent.FLAG_ACTIVITY_MULTIPLE_TASK;
	            break;
	    }
	}
	final boolean launchTaskBehind = r.mLaunchTaskBehind
	        && !launchSingleTask && !launchSingleInstance
	        && (launchFlags & Intent.FLAG_ACTIVITY_NEW_DOCUMENT) != 0;
	if (r.resultTo != null && (launchFlags & Intent.FLAG_ACTIVITY_NEW_TASK) != 0) {
	    // For whatever reason this activity is being launched into a new
	    // task...  yet the caller has requested a result back.  Well, that
	    // is pretty messed up, so instead immediately send back a cancel
	    // and let the new task continue launched as normal without a
	    // dependency on its originator.
	    Slog.w(TAG, "Activity is launching as a new task, so cancelling activity result.");
	    r.resultTo.task.stack.sendActivityResultLocked(-1,
	            r.resultTo, r.resultWho, r.requestCode,
	            Activity.RESULT_CANCELED, null);
	    r.resultTo = null;
	}

这就解析了为什么5.0(含)之后的系统即便启动的页面设置**launchMode**为**singleTask**或**singleInstance**，**onActivityResult**依旧可以正常工作。 


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
