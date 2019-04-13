---
layout: post
comments: true
title: '同步aar到jCenter与maven central'
date: '2015-10-25'
header-img: "img/post-bg-android.jpg"
tags:
     - java
     - android
     - maven
author: 'Codeboy'
---

目前gradle使用的越来越多了，自己平时也在github上放了一些代码，但是别人使用起来非常的麻烦，需要下载项目，导入项目，比较的繁碎。经历了一天的实战，终于成功了将自己在github上的一些项目规整后同步到了jcenter与maven central中。大家可以参考英文版的文档[https://github.com/lopspower/gradle-jcenter-publish](https://github.com/lopspower/gradle-jcenter-publish)

	android两个比较公共仓库jCenter与maven central，android studio之前默认使用maven central仓库，最新版中已经将jCenter设置为默认仓库，对于开发者来说，jcenter的操作以及管理页面都更加的友好，所以这里选择先将aar上传到jCenter中，之后同步到maven central。在同步到maven central之前，我们需要创建在maven central创建issue，允许指定的groupId同步仓库即可，之后在jCenter中同步完成后，在控制台完成同步即可。

1. 使用Android Studio创建一个android类库，比如: [AlignTextView](https://github.com/androiddevelop/AlignTextView)

2. 在build.gradle中添加`apply plugin: 'com.android.library'` ，需要注意的是尽量将module的名字修正，因为最后的module的名字将会成为artifactId。
 
3. 注册 [Sonatype](https://issues.sonatype.org/secure/Dashboard.jspa), 我注册的名字是 `yuedong`（Maven Central）

4. 在 [Sonatype OSS Repository](https://issues.sonatype.org/secure/Dashboard.jspa) 注册一个项目主题:
`Create → Create Issue → Community Support - Open Source Project Repository Hosting → New Project → with groupid com.github.lopspower`<br>需要注意，一个JIRA issue的顶级groupId是必要的，之后所有的子groupId将都有部署的权限。（例如顶级groupId为me.codeboy,状态变为resolved之后，那么me.codeboy.android将可以直接部署）

5. 注册Bintray用户，可以直接使用github用户登录，此处假设依旧使用`yuedong`这个名字进行注册。

6. 将Bintray账户编辑中的`automatically signing of the uploaded content`开启:<br>[配置地址](https://bintray.com/profile/edit) → GPG Signing → copy paste your gpg armored `public` and `private` keys.<br>UNIX/MAC下可以通过以下命令获取 `public_key_sender.asc` 和 `private_key_sender.asc`，WINDOWS下可以根据[http://www.gpg4win.org/](http://www.gpg4win.org/)的说明完成。

		gpg --gen-key    # 生成钥匙对
		gpg --list-keys  # 获取publicId，下步中要使用
		gpg --keyserver hkp://pool.sks-keyservers.net --send-keys PubKeyId  # 公布公钥
		gpg -a --export androiddevelop@qq.com > public_key_sender.asc
		gpg -a --export-secret-key androiddevelop@qq.com > private_key_sender.asc  


7. 在Bintray的配置页面 [web page](https://bintray.com/profile/edit) 配置自动签名:
`Repositories → Maven → Check the "GPG Sign uploaded files automatically" → Update`

8. 在Bintray的配置页面 [web page](https://bintray.com/profile/edit) 你可以获取`Bintray API Key` (复制一下，后续使用)

9.  在Bintray的配置页面[web page](https://bintray.com/profile/edit)，从 `Account`链接中可以配置 `Sonatype OSS User` (在第3步已经创建) 。

10. 将下面两行加入项目根目录中的 `build.gradle` 的 `buildScript` 节点下classpath, 如下所示:

	    buildscript {
		      repositories {
		          jcenter()
		      }
		      dependencies {
		          classpath 'com.android.tools.build:gradle:1.3.0'
		          //添加内容
		          classpath 'com.github.dcendents:android-maven-gradle-plugin:1.3'
		          classpath 'com.jfrog.bintray.gradle:gradle-bintray-plugin:1.1'
		      }
		  }
		  
		  allprojects {
		      repositories {
		          jcenter()
		      }
		  }

11. 修改类库下的 `build.gradle` ，将其配置从	

	     apply plugin: 'com.android.library'
		  apply plugin: 'com.github.dcendents.android-maven'
		  apply plugin: "com.jfrog.bintray"
		  
		  // This is the library version used when deploying the artifact
		  version = "1.0.0"
		  
		  android {
		      compileSdkVersion 23
		      buildToolsVersion "23.0.1"
		  
		      defaultConfig {
		          minSdkVersion 11
		          targetSdkVersion 23
		          versionCode 4
		          versionName version
		      }
		      buildTypes {
		          release {
		              minifyEnabled false
		              proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
		          }
		      }
		  }
		  
		  dependencies {
		      compile fileTree(dir: 'libs', include: ['*.jar'])
		  }
		  
		  def siteUrl = 'https://github.com/androiddevelop/AlignTextView'      // Homepage URL of the library
		  def gitUrl = 'https://github.com/androiddevelop/AlignTextView.git'   // Git repository URL
		  group = "me.codeboy.android"                                          // Maven Group ID for the artifact
		  
		  install {
		      repositories.mavenInstaller {
		          // This generates POM.xml with proper parameters
		          pom {
		              project {
		                  packaging 'aar'
		  
		                  // Add your description here
		                  name 'me.codeboy.android.align-text-view' // TODO 
		                  description = 'Description of your project HERE' // TODO
		                  url siteUrl
		  
		                  // Set your license
		                  licenses {
		                      license {
		                          name 'The Apache Software License, Version 2.0'
		                          url 'http://www.apache.org/licenses/LICENSE-2.0.txt'
		                      }
		                  }
		                  developers {
		                      developer {
		                          id 'codeboy' // TODO
		                          name 'yuedong' // TODO
		                          email 'androiddevelop@qq.com' // TODO
		                      }
		                  }
		                  scm {
		                      connection gitUrl
		                      developerConnection gitUrl
		                      url siteUrl
		                  }
		              }
		          }
		      }
		  }
		  
		  task sourcesJar(type: Jar) {
		      from android.sourceSets.main.java.srcDirs
		      classifier = 'sources'
		  }
		  
		  task javadoc(type: Javadoc) {
		      source = android.sourceSets.main.java.srcDirs
		      classpath += project.files(android.getBootClasspath().join(File.pathSeparator))
		  }
		  
		  task javadocJar(type: Jar, dependsOn: javadoc) {
		      classifier = 'javadoc'
		      from javadoc.destinationDir
		  }
		  artifacts {
		      archives javadocJar
		      archives sourcesJar
		  }
		  
		  Properties properties = new Properties()
		  properties.load(project.rootProject.file('local.properties').newDataInputStream())
		  
		  bintray {
		      user = properties.getProperty("bintray.user")
		      key = properties.getProperty("bintray.apikey")
		  
		      configurations = ['archives']
		      pkg {
		          repo = "maven"
		          // it is the name that appears in bintray when logged
		          name = "AlignTextView"
		          websiteUrl = siteUrl
		          vcsUrl = gitUrl
		          licenses = ["Apache-2.0"]
		          publish = true
		          version {
		            gpg {
		                sign = true
		                passphrase = properties.getProperty("bintray.gpg.password") 
		            }
		        }        
		      }
		  }

12. 将以下信息加入 `local.properties` ，谨记不要将此文件公开。

	    bintray.user=<your bintray username>
	    bintray.apikey=<your bintray api key>
	    
	    bintray.gpg.password=<your gpg signing password>
	    bintray.oss.user=<your sonatype username>
	    bintray.oss.password=<your sonatype password>
  
13. 打开 "Android Studio" 中的终端病执行以下命令:

	    gradle bintrayUpload


14. 从 [Bintray](https://bintray.com/) → My Recent Packages → AlignTextView → Add to Jcenter → Check the box → Group Id = "me.codeboy.android".
等审核后将会被加入jCenter中，审核过程蛮快的，通过后会邮件通知，可以在 [jcenter.bintray.com](http://jcenter.bintray.com/) 查看是否自己的类库已经加到仓库中。现在你可以通过一下配置加入次类库。

		 build.gradle (Project):
		  
		    repositories {
		      jcenter()
		    }
		  
		  
		 build.gradle (Module):
		  
		    dependencies {
		      compile 'me.codeboy.android:align-text-view:2.0.2'
		    }

  
15. 最后通过Bintray控制台同步类库到Maven Central: Bintray → My Recent Packages → me.codeboy.android:align-text-view → Maven Central → Sync.

16. 现在也可以maven central进行类库导入了。
	
		build.gradle (Project):
		
	    repositories {
	     mavenCentral()
	    }
	    
	    build.gradle (Module):
	  
	    dependencies {
	      compile 'me.codeboy.android:align-text-view:2.0.2'
	    }

17. 同步jCenter到maven central可以在第一次通过后，之后的更新可以通过配置直接同步，配置如下(module中的build.gradle部分配置如下):
	
		 bintray {
	      user = properties.getProperty("bintray.user")
	      key = properties.getProperty("bintray.apikey")
	  
	      configurations = ['archives']
	      pkg {
	          repo = "maven"
	          // it is the name that appears in bintray when logged
	          name = "AlignTextView"
	          websiteUrl = siteUrl
	          vcsUrl = gitUrl
	          licenses = ["Apache-2.0"]
	          publish = true
	          version {
	            gpg {
	                sign = true
	                passphrase = properties.getProperty("bintray.gpg.password") 
	            }
	            //添加部分
	            mavenCentralSync {
	                 sync = true
	                 user = properties.getProperty("bintray.oss.user")
	                 password = properties.getProperty("bintray.oss.password")
	                 close = '1'
	             }
	        }        
	      }


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
