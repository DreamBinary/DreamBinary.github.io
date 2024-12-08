---
title: Compose AlertDialog+ LazyVerticalGrid 写个颜色选择器
categories: [ Android ]
tags: [ Android ]
---

# 前言

在最近的学习过程中，有个主题色的选择更换需求，学习完成后就来这发文章啦！[完整代码](#index) 在这。

---

# 一、最终效果

![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/58a398998a1e1009c33bed9d6b1b5cda.gif#pic_center)
这里简单的模拟了一下主题色的更换，可以看到颜色更换和持久化保存都没问题。

---

# 二、具体实现

## 0、颜色选择

更换颜色最主要的当然是选择颜色啦，代码如下：

```kotlin
@OptIn(ExperimentalFoundationApi::class)
@androidx.compose.runtime.Composable
fun ColorPicker(
    colorList: List<Color>,
    currentShowColor: Color,
    onColorConfirm: (Int) -> Unit
) {
    var currentColor by remember {
        mutableStateOf(currentShowColor)
    }

    LazyVerticalGrid(
        // 单元格展现形式
        cells = GridCells.Fixed(5),
        verticalArrangement = Arrangement.Center,
        horizontalArrangement = Arrangement.Center
    ) {
        itemsIndexed(colorList) { index, item ->
            Surface(
                modifier = Modifier
                    //宽高比
                    .aspectRatio(1f)
                    .padding(4.dp)
                    .clickable {
                        currentColor = item
                        onColorConfirm(index)
                    },
                shape = CircleShape,
                color = item,
                border = BorderStroke(1.dp, Color.Black),
            ) {
                if (currentColor == item) {
                    Icon(Icons.Default.Favorite, null, modifier = Modifier.padding(10.dp))
                }
            }
        }
    }
}
```

这里传入三个参数，colorList 是所有颜色的一个列表，currentShowColor 是当前展示的颜色（即效果展示中的背景色），onColorConfirm
是确认更换颜色在后边会用到。颜色以 LazyVerticalGrid 加 Surface 进行展现，这里要注意在 modifier 加上 .aspectRatio(1f)
即宽高比，否则你的效果会是这样的：
![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/130d3ad8a28012b64f09680fbb3cb132.png#pic_center)
Icon 则用来标记选中或点击了哪个颜色， currentColor 用于触发它的重绘。除此以外，还有一个点要注意在新版中上面这种
LazyVerticalGrid 已经被弃用，可以用下面这种代替（大体一样）：

```kotlin
    androidx.compose.foundation.lazy.grid.LazyVerticalGrid(
        columns = androidx.compose.foundation.lazy.grid.GridCells.Fixed(5),
        contentPadding = PaddingValues(5.dp),
        verticalArrangement = Arrangement.Center,
        horizontalArrangement = Arrangement.Center,
        ) { ... }
```

## 1、弹对话框

从效果图可以看到展现颜色选择器这部分我是用对话框来实现，如下：

```kotlin
@Composable
fun ColorPickerDialog(
    textContent: @Composable (() -> Unit),
    onConfirm: () -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(text = "颜色选择器") },
        // 这里上下的 text 可不同哦
        // text: @Composable (() -> Unit)? = null,
        text = {
            textContent()
        },
        // 确认按钮
        confirmButton = {
            TextButton(
                onClick = {
                    onConfirm()
                    onDismiss()
                }
            ) {
                Text("确定")
            }
        },
        // 取消按钮
        dismissButton = {
            TextButton(
                onClick = onDismiss
            ) {
                Text("取消")
            }
        }
    )
}
```

三个参数，textContent 即对话框的内容（稍后会传入上面我们写好的颜色选择），onConfirm 确认功能（确认更换颜色和颜色的持久化），onDismiss
取消功能（没啥用就关闭对话框）。

## 2、功能集合

上面已经写好了主要部分，现在将他们组合起来用一下：

```kotlin
@Composable
fun Test(
    showColor: MutableState<Color>,
    colorList: List<Color>
) {
    var showDialogState by remember {
        mutableStateOf(false)
    }
    val context = LocalContext.current
    var currentColorIndex = 0
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = showColor.value
    ) {
        TextButton(onClick = {
            showDialogState = true
        }) {
            Text("点我点我")
        }
        if (showDialogState) {
            ColorPickerDialog(
                { ColorPicker(colorList, showColor.value) { currentColorIndex = it } },
                {
                    // 确定更换颜色
                    showColor.value = colorList[currentColorIndex]
                    // 持久化保存
                    SpMMKVUtil.put("color", currentColorIndex)
                    Toast.makeText(context, "早啊", Toast.LENGTH_SHORT).show()

                },
                { showDialogState = false }
            )
        }
    }
}

```

这里 showDialogState 用于控制对话框的显隐，currentColorIndex 作为确认按钮和颜色选择直接的中间商，帮忙暂时存一下。另外这里要实现开头那样的效果的话不应该直接将
showColor: MutableState<Color> 传入 ColorPicker
（我之前就是这么干的）。如果将它传入并用它来更换颜色的话，我们点击一个颜色它就变成了那个颜色，这样的话确认按钮就可以删掉了。其实这样也挺好，有的软件就是这样干的。看看这样的效果：
![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/8dd9aac19b713f68bfc4c376fe283d82.gif#pic_center)
从代码中可以看到这里用了一个 SpMMKVUtil 来持久化，它是封装了 MMKV 的一个工具，（ MMKV 是一个轻量级高效存储数据库，腾讯开发的哦，存储读写效率高，
最近刚学就用了一下），推荐大家也可以去学一下，网上教程一大把，这就不说了

## 3、功能测试

先扔代码：

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val colorList = listOf(
            Color(0xFF8FDAFC),
            Color(0xFFB34D9E),
            Color(0xFF44BBA3),
            Color(0xFF8AB34D),
            Color(0xFFA25E5E),
            Color(0xFF778888),
            Color(0xFFCC3352),
        )
//        val showColor = remember {
//            mutableStateOf(colorList[SpMMKVUtil.getInt("color")!!])
//        }
        val showColor: MutableState<Color> by lazy {
            mutableStateOf(colorList[SpMMKVUtil.getInt("color") ?: 0])
        }
        setContent {
            MyColorPicker2Theme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color.White
                ) {
                    Test(showColor, colorList)
                }
            }
        }
    }
}
```

colorList 就是我们的颜色列表用来展示和选择的。这里的注释应该要注意到，报错如下：
![在这里插入图片描述](https://i-blog.csdnimg.cn/blog_migrate/50bee21d8d899e27af494ed7e5fccd6e.png)
它只能在带有 @Composable 注释的时候才能用。所以用个 lazy 来解决一下。到这所以代码都讲完了。

---

# 三、<a id="index">完整代码</a>

记得添加 MMKV 依赖

```kotlin
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.GridCells
import androidx.compose.foundation.lazy.LazyVerticalGrid
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.example.mycolorpicker2.SpMMKVUtil
import com.example.mycolorpicker2.ui.theme.MyColorPicker2Theme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val colorList = listOf(
            Color(0xFF8FDAFC),
            Color(0xFFB34D9E),
            Color(0xFF44BBA3),
            Color(0xFF8AB34D),
            Color(0xFFA25E5E),
            Color(0xFF778888),
            Color(0xFFCC3352),
        )
        val showColor = remember {
            mutableStateOf(colorList[SpMMKVUtil.getInt("color")!!])
        }
//        val showColor: MutableState<Color> by lazy {
//            mutableStateOf(colorList[SpMMKVUtil.getInt("color") ?: 0])
//        }
        setContent {
            MyColorPicker2Theme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color.White
                ) {
                    Test(showColor, colorList)
                }
            }
        }
    }
}

@Composable
fun Test(
    showColor: MutableState<Color>,
    colorList: List<Color>
) {
    var showDialogState by remember {
        mutableStateOf(false)
    }
    val context = LocalContext.current
    var currentColorIndex = 0
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = showColor.value
    ) {
        TextButton(onClick = {
            showDialogState = true
        }) {
            Text("点我点我")
        }
        if (showDialogState) {
            ColorPickerDialog(
                { ColorPicker(colorList, showColor.value) { currentColorIndex = it } },
                {
                    // 确定更换颜色
                    showColor.value = colorList[currentColorIndex]
                    // 持久化保存
                    SpMMKVUtil.put("color", currentColorIndex)
                    Toast.makeText(context, "早啊", Toast.LENGTH_SHORT).show()

                },
                { showDialogState = false }
            )
        }
    }
}


@Composable
fun ColorPickerDialog(
    textContent: @Composable (() -> Unit),
    onConfirm: () -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(text = "颜色选择器") },
        // 这里上下的 text 可不同哦
        // text: @Composable (() -> Unit)? = null,
        text = {
            textContent()
        },
        // 确认按钮
        confirmButton = {
            TextButton(
                onClick = {
                    onConfirm()
                    onDismiss()
                }
            ) {
                Text("确定")
            }
        },
        // 取消按钮
        dismissButton = {
            TextButton(
                onClick = onDismiss
            ) {
                Text("取消")
            }
        }
    )
}


@OptIn(ExperimentalFoundationApi::class)
@androidx.compose.runtime.Composable
fun ColorPicker(
    colorList: List<Color>,
    currentShowColor: Color,
    onColorConfirm: (Int) -> Unit
) {
    var currentColor by remember {
        mutableStateOf(currentShowColor)
    }

    LazyVerticalGrid(
        // 单元格展现形式
        cells = GridCells.Fixed(5),
        verticalArrangement = Arrangement.Center,
        horizontalArrangement = Arrangement.Center
    ) {
        itemsIndexed(colorList) { index, item ->
            Surface(
                modifier = Modifier
                    //宽高比
                    .aspectRatio(1f)
                    .padding(4.dp)
                    .clickable {
                        currentColor = item
                        onColorConfirm(index)
                    },
                shape = CircleShape,
                color = item,
                border = BorderStroke(1.dp, Color.Black),
            ) {
                if (currentColor == item) {
                    Icon(Icons.Default.Favorite, null, modifier = Modifier.padding(10.dp))
                }
            }
        }
    }
}

```

---

# 最后

文章就到这，希望对你有帮助，欢迎评论，拜拜！
