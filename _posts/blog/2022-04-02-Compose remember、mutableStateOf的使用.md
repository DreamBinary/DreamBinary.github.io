---
title: Compose remember、mutableStateOf的使用
categories: [ blog ]
tags: [ Android ]
---
---

# 前言
学习 Jetpack Compose，起步的一定是 TextView 即 Compose 中 Text。记录一下开始学习时遇到一些小问题。


# 一、初始代码

```kotlin
@Composable
fun MyText() {
    var text = "哈哈哈"
    Text(
        text = text,
        modifier = Modifier.clickable {
            text = "呵呵"
        }
    )
}
```
这里加了一个给 Text 加了一个 clickable 即可点击，由于 Compose 是响应式编程，这里即加了一个监听器。但是呢，怎么使劲点也没反应，如下图：

![img](./assets/post_img/3aa3920879c5b13760a40023bb299a19_MD5.gif)


# 二、remember、mutableStateOf 初使用
经一番搜索才知道还有 remember、mutableStateOf 的存在，于是加上他们试了一下：

![img](./assets/post_img/929d97119999921ba9e4e0198d1be4e1_MD5.png)
从上图可以看到，有报红警告。将鼠标置于 text 之上，可以看见 text 是 MutableState< String > 而不是 String 类型。于是把代码改成下面这样子：

```kotlin
@Composable
fun MyText() {
//    var text = "哈哈哈"
    val text = remember {
        mutableStateOf("哈哈哈")
    }
    Text(
        text = text.value,
        modifier = Modifier.clickable {
            text.value = "呵呵"
        }
    )
}
```
加了个 value 之后就可以得到和设置 MutableState< String > 里的值了，就可以看到我们想要的效果了：

![img](./assets/post_img/7165af1f8e5448b2c2b5f92df25c85a3_MD5.gif)

# 三、by 的使用
在上面取值和赋值还要用个 value 略显麻烦。使用 by 进行委托就能省去此麻烦：

![img](./assets/post_img/8a3240398802c18a264d49498d0e3287_MD5.png)
可以看到此时 text 与之前不一样是 String 类型，于是我们可以直接进行操作。下面是完整代码：

```kotlin
class MainActivity : ComponentActivity() {
    @SuppressLint("ResourceType")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MyComposeTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    MyText()
                }
            }
        }
    }
}

@Composable
fun MyText() {
//    var text = "哈哈哈"
    var text by remember {
        mutableStateOf("哈哈哈")
    }
    Text(
        text = text,
        modifier = Modifier.clickable {
            text = "呵呵"
        }
    )
}
```
# 四、by 的回忆
不知道有没人已经忘了 by 了呢？关键字不应该忘吧。但是，我是忘记了。
在 Kotlin 中使用 by 实现属性委托。语法结构为：

```kotlin
val/var < Property Name > : < Type > by  < Expression >
val/var A: < Type > by B
```

对于指定了委托对象的属性 ( Property Name )，它的实现逻辑交给委托对象 ( Expression ) 处理实现。委托对象 (B) 会接管该属性 (A) 的 getter 和 setter 操作。所以，委托对象 (B) 会提供 (A) 的 getValue 、setValue (val 属性不用) 方法。在后面的 Compose 的学习中，也会遇到 val 改 var 时 AS 会提示设置 setValue 方法。
# 五、remember、mutableStateOf 的理解
回到主题 remember、mutableStateOf，对这两的理解我是这样的

```kotlin
mutableStateOf --- 表明某个变量是有状态的，对变量进行监听，当状态改变时，触发重绘。
remember --- 记录变量的值，使得下次使用改变量时不进行初始化。
	使用 remember 存储对象的可组合项会创建内部状态，使该可组合项有状态。
	remember 会为函数提供存储空间，将 remember 计算的值储存，当 remember 的键改变的时候会进行重新计算值并储存。
rememberSaveable --- 在这里顺带提一下,rememberSaveable 可以在重组后保持状态,也可以在重新创建 activity 和进程后保持状态。
```
我们在创建有状态对象是务必记得使用它们，在 Compose 的学习之路上我们会经常用到他们。

![img](./assets/post_img/3e6b43e587188debf4512c27efc1ea5b_MD5.png)
![img](./assets/post_img/7884145cf28ca8b928384bfb6d94c622_MD5.png)
我们在 AS 的提示功能中可以看到他们的种类非常的多，绝大部分也比较经常用到。

# 最后
文章就到这，拜拜！
