---
layout: post
comments: true
title: 'Java源码在线编译执行'
date: '2019-06-14'
header-img: "img/post-bg-java.jpg"
tags:
     - java
author: 'Codeboy'
---

在告警平台中，经常会用到规则配置，一些简单的规则配置可以使用基本表达式来完成，对于一些复杂的规则，很难进行表达或者完全覆盖，如果告警规则等由一些具备编程能力的开发同学来完成，是否可以考虑规则直接使用源码来描述，动态执行呢？这样可以在系统不重新部署的情况下加入新的规则配置。

下面我们根据 `JDK6` 中新增的 `JavaCompiler` ，来实现源码线上编译，完成简单类的线上运行，并获取对应的结果。

### 约定

约定测试类需要实现无参 `execute` 方法，在编译成功后，使用反射的方法调用该方法。下面是我们用来测试的一个代码:

```java
package me.codeboy.test.compile;

/**
 * 测试class
 * Created by yuedong.li on 2019-06-14
 */
public class FooClass {

    public String execute() {
        System.out.println("invoke method");
        return "SUCCESS";
    }
}
```

打印 `invoke method` , 并返回对应 `SUCCESS` 结果。

### 准备

编译java代码需要指定编译参数和classpath，使用 `JavaCompiler` 也是一样的，需要把执行测试类的一些基础依赖添加到编译环境中来，针对本文中的示例，使用基本配置即可，作者测试时使用的配置如下：
```
  编译参数:  -target 1.8
classpath: 工程中的其他的class作为classpath
  输出目录: 工程根目录下的CodeTest目录
```

### 操作

#### 定义JavaFileObject

用于保存源码，jdk中提供了 `SimpleJavaFileObject` , 可以在该类的基础上简单修改即可。

```java
package me.codeboy.test.compile;

import javax.tools.SimpleJavaFileObject;
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.net.URI;

/**
 * java file object
 * Created by yuedong.li on 2019-06-13
 */
public class MyJavaFileObject extends SimpleJavaFileObject {
    private String source;

    public MyJavaFileObject(String name, String source) {
        super(URI.create("String:///" + name + Kind.SOURCE.extension), Kind.SOURCE);
        this.source = source;
    }

    @Override
    public CharSequence getCharContent(boolean ignoreEncodingErrors) {
        if (source == null) {
            throw new IllegalArgumentException("source == null");
        }
        return source;
    }

    @Override
    public OutputStream openOutputStream() {
        return new ByteArrayOutputStream();
    }
}
```

#### 定义classloader

加载字节码，为什么定义呢，因为 `defineClass` 是 `protected` 修饰的, 实际上是做一个中转。

```java
package me.codeboy.test.compile;

/**
 * classLoader，在当前classLoader的基础上，load进来自己载入的类
 * Created by yuedong.li on 2019-06-13
 */
public class MyClassLoader extends ClassLoader {

    public MyClassLoader() {
        super(MyClassLoader.class.getClassLoader());
    }

    Class<?> getTestClass(byte[] classBytes) {
        return defineClass(null, classBytes, 0, classBytes.length);
    }
}
```

#### CodeRuntime

源码执行器，进行的操作如下:

- 源码去除package头部
- 获取className
- 为生成的class指定目录
- 编译源码，生成字节码
- 加载字节码，反射调用execute方法

```java
package me.codeboy.test.compile;

import javax.tools.*;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * code runtime
 * Created by yuedong.li on 2019/06/14.
 */
public class CodeRuntime {
    private static final Pattern CLASS_PATTERN = Pattern.compile("class\\s+([$_a-zA-Z][$_a-zA-Z0-9]*)\\s*");
    private static final List<String> OPTIONS = new ArrayList<>(); // 编译参数
    private static final List<File> CLASSPATH = new ArrayList<>(); // classpath
    private static final String PROJECT_DIR = System.getProperty("user.dir"); // 工程目录
    private static final String TMP_DIR = "CodeTest"; // 存储编译产物

    static {
        OPTIONS.add("-target");
        OPTIONS.add("1.8");
        File classRootFile = new File(PROJECT_DIR, TMP_DIR);
        if (!classRootFile.exists()) {
            classRootFile.mkdir();
        }
        //根据实际情况添加对应的环境变量，class或者jar都可以
        CLASSPATH.add(new File(classRootFile, "build/classes/main"));
    }

    /**
     * 执行代码
     *
     * @param code 源码
     * @return 返回结果
     * @throws IOException io异常
     */
    public static String run(String code) throws IOException {
        if (code == null || code.length() == 0) {
            return "代码为空";
        }
        code = code.trim();
        //去除package
        if (code.startsWith("package")) {
            int index = code.indexOf("\n");
            if (index != -1) {
                code = code.substring(index + 1);
            }
        }

        //找出入口类名
        Matcher matcher = CLASS_PATTERN.matcher(code);
        String clsName;
        if (matcher.find()) {
            clsName = matcher.group(1);
        } else {
            throw new IllegalArgumentException("No such class name in " + code);
        }

        //在对应代码生成目录中以时间戳为目录名建立目录
        File classRootFile = new File(PROJECT_DIR, TMP_DIR);
        final String time = String.valueOf(System.currentTimeMillis());
        File parentDir = new File(classRootFile, time);
        if (!parentDir.exists()) {
            parentDir.mkdir();
        }

        File classFile = new File(parentDir, clsName + ".class");
        File[] outputs = new File[]{parentDir};

        //开始进行编译
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        DiagnosticCollector<JavaFileObject> collector = new DiagnosticCollector<>();
        StandardJavaFileManager fileManager = compiler.getStandardFileManager(null, null, null);
        fileManager.setLocation(StandardLocation.CLASS_PATH, CLASSPATH);
        fileManager.setLocation(StandardLocation.CLASS_OUTPUT, Arrays.asList(outputs));

        JavaFileObject javaFileObject = new MyJavaFileObject(clsName, code);
        Boolean result = compiler.getTask(null, fileManager, collector, OPTIONS, null, Arrays.asList(javaFileObject)).call();
      
        //编译结果，如果有错误，返回对应错误信息
        if (!result) {
            List list = collector.getDiagnostics();
            StringBuilder info = new StringBuilder();
            for (Object object : list) {
                Diagnostic d = (Diagnostic) object;
                String line = d.getMessage(Locale.ENGLISH);
                info.append(line).append("\n");
            }
            String infoStr = info.toString();
            if (infoStr.endsWith("\n")) {
                infoStr = infoStr.substring(0, infoStr.length() - 1);
            }
            return "编译失败:" + infoStr;
        }

        //读取字节码，使用类加载器加载
        byte[] classBytes = getBytesFromFile(classFile);
        MyClassLoader classloader = new MyClassLoader();
        try {
            Class clazz = classloader.getTestClass(classBytes);
            Object instance = clazz.newInstance();

            Method method = clazz.getMethod("execute");
            return method.invoke(instance).toString();
        } catch (NoSuchMethodException e) {
            return "请实现execute无参方法";
        } catch (Exception e2) {
            return e2.getMessage();
        }
    }

    /**
     * 文件转化为字节数组
     *
     * @param file 文件
     * @return 字节数组
     */
    private static byte[] getBytesFromFile(File file) throws IOException {
        if (file == null) {
            return null;
        }
        FileInputStream in = new FileInputStream(file);
        ByteArrayOutputStream out = new ByteArrayOutputStream(4096);
        byte[] b = new byte[4096];
        int n;
        while ((n = in.read(b)) != -1) {
            out.write(b, 0, n);
        }
        in.close();
        out.close();
        return out.toByteArray();
    }
}
```

### 测试

对 `CoideRuntime` 进行源码测试，将 `FooTest` 类的源码作为字符串输入后执行。

  ```
  package me.codeboy.test.compile;
  
  import java.io.IOException;
  
  /**
   * 测试代码
   * Created by yuedong.li on 2019-06-13
   */
  public class Test {
      public static void main(String[] args) throws IOException {
          String source = "package me.codeboy.test.compile;" +
                  "\n" +
                  "/**\n" +
                  " * 测试class\n" +
                  " * Created by yuedong.li on 2019-06-14\n" +
                  " */\n" +
                  "public class FooClass { \n" +
                  "    public String execute() {\n" +
                  "        System.out.println(\"invoke method\");" +
                  "        return \"SUCCESS\";"+
                  "    }" +
                  "}";
          String result = CodeRuntime.run(source);
          System.out.println(result);
      }
  }
  ```



执行后，输出结果如下：

```nohighlight
invoke method
SUCCESS
```

符合预期结果。


### 小结

根据上面的讲述，针对告警平台等的一些规则可以使用源码来编写，虽然需要一点开发成本，但是灵活度大幅度提升，遇到合适的场景可以考虑尝试。


> 如有任何知识产权、版权问题或理论错误，还请指正。
>
> 转载请注明原作者及以上信息。
