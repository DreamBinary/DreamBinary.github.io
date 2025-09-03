---
title: Compose Modifier.swipeable() 写个侧拉组件
categories: [ blog ]
tags: [ Android ]
---
---
# 前言
大家使用 QQ 的时候，肯定见过它：
![img](./assets/post_img/652654655e9d6360bd4f99639509f54b_MD5.jpg)
这次，我想用 Compose 来写一个类似的，大家可以和我一步步来，也可以直接看[完整代码](#index)。

---

# 一、工具选择
在 Compose 里有 SwipeToDismiss、Modifier.swipeable () 两种供我们使用， SwipeToDismiss 的底层使用 swipeable 实现的，使用的时候侧拉会占满一整行，像这样：![img](./assets/post_img/46f30594495dda1e838a7a2a7b75fd06_MD5.gif)
和我们想做的不太一致，也和我们平常习惯用的不一样。所以就不使用它了，用 Modifier.swipeable ()  来实现。

---

# 二、具体实现
## 1. 方法定义
先看看最后方法的定义和它的参数：

```kotlin
/**
 * @Description: 侧拉滑动组件
 * @Param:
 * @param modifier 没啥好说的
 * @param swipeItemWidth 侧拉组件的宽度
 * @param isShowSwipe 判断是否显示
 * @param swipeDirection 判断侧拉方向
 * @param swipeContent 侧拉组件的内容
 * @param content 主题内容
 * @return:
 */
@OptIn(ExperimentalMaterialApi::class, ExperimentalAnimationApi::class)
@Composable
fun SwipeItem(
    modifier: Modifier = Modifier,
    swipeItemWidth: Float,
    isShowSwipe: Boolean = true,
    swipeDirection: SwipeDirection = SwipeDirection.ENDTOSTART,
    swipeContent: @Composable () -> Unit,
    content: @Composable () -> Unit
) {}
```
这里的方向定义，我们设置了一个枚举类：

```kotlin
enum class SwipeDirection {
    STARTTOEND,
    ENDTOSTART
}
```
表示不同的两个方向。
其他的看看注释应该就懂了。
## 2. 变量准备

```kotlin
// 记录一下滑动方向, 便于下面的判断
val isEndToStart = swipeDirection == SwipeDirection.ENDTOSTART
val swipeState = rememberSwipeableState(initialValue = false)
// 滑动偏移量, 偏移量指 content 的左边的偏移
val dx: Float = if (isEndToStart) {
    -swipeItemWidth
} else {
    swipeItemWidth
}
// 偏移 dx 时显示, 两个方向不同, 所以上面对 dx 做判断
val anchors = mapOf(dx to true, 0f to false)
Row(modifier = modifier) {
	...主体内容和侧拉内容...
}
```
这里我们定义了一些量，为下面的滑动、侧拉组件显示做准备。要注意的是 dx 的值，因为左拉和右拉的偏移量要与 swipeState 的 true 对应，当偏移距离为 swipeItemWidth 时 swipeState 的 value 就会变成 true，swipeState 的 value 我们会用到侧拉组件的显示与否中去。这里的 anchors 我们一会用到 swipeable () 中去。接下来我们往里填充体内容和侧拉内容就行了。
## 3. 主体内容
代码如下：
```kotlin
Box(
    modifier = Modifier
//          .fillMaxWidth()
        // 这里要用 weight 才会有挤压的效果
        // 而且用 fillMaxWidth() 滑动组件会被遮挡
        .weight(1f)
        .offset {
            IntOffset(
                swipeState.offset.value.toInt(), 0
            )
        }
        // swipeable() 是滑动组件的核心所在
        .swipeable(
            state = swipeState,
            anchors = anchors,
            thresholds = { _, _ -> FractionalThreshold(1f) },
            orientation = Orientation.Horizontal
        )
) {
    // 主体内容
    content()
}
```
代码中的 weight 在侧拉组件显示和隐藏时，会产生挤压效果，我们一会会看到。
offset 会使主体内容随手的滑动产生偏移效果。
swipeable () 前两个参数，我们刚才定义过了；thresholds 常用作定制不同锚点间吸附效果的临界阈值，常用有 FixedThreshold (Dp) 和 FractionalThreshold (Float) 两种；orientation 没啥好讲的吧，这里肯定是水平啊（大家有兴趣也可以试试垂直）。
到这我们主体内容部分就完成了，它会进行偏移。
## 4. 侧拉内容
终于到我们的主角侧拉组件了。因为等下我们会用到两次侧拉组件（为什么呢？一会就知道了），所以我们把他抽离出来：

```kotlin
private fun RowScope.SwipeChild(
    isShowSwipe: Boolean,
    swipeState: SwipeableState<Boolean>,
    swipeContent: @Composable () -> Unit
) {
    // 这里用动画进行侧拉组件显示和隐藏
    AnimatedVisibility(visible = isShowSwipe && swipeState.currentValue) {
         Box(
            modifier = Modifier
                .align(alignment = Alignment.CenterVertically)
        ) {
            swipeContent()
        }
    }
}
```
这里面内容比较简单，当允许显示并且 swipeState 的 value 为 true 即主体内容滑动偏移达到我们设定的值时，就显示侧拉内容。但是，其实这里漏了一个东西，就是当我们点击完侧拉内容后，它应该隐藏起来，那应该怎么做呢，加上它就行了：

```kotlin
scope.launch {
	swipeState.animateTo(false)
}
```
它会将 swipeState 的值改成 false，这样侧拉内容就隐藏了。最后侧拉内容的代码如下（就往上面的代码块加了几行）：

```kotlin
/**
 * @Description: 侧拉组件显示与隐藏
 * @Param:
 * @param isShowSwipe
 * @param swipeState
 * @param swipeContent
 * @return:
 */
@OptIn(ExperimentalMaterialApi::class, ExperimentalAnimationApi::class)
@Composable
private fun RowScope.SwipeChild(
    isShowSwipe: Boolean,
    swipeState: SwipeableState<Boolean>,
    swipeContent: @Composable () -> Unit
) {
    val scope = rememberCoroutineScope()
    // 这里用动画进行侧拉组件显示和隐藏
    AnimatedVisibility(visible = isShowSwipe && swipeState.currentValue) {
        Box(modifier = Modifier
            .align(alignment = Alignment.CenterVertically)
            .clickable {
                scope.launch {
                    swipeState.animateTo(false)
                }
            }) {
            swipeContent()
        }
    }
}
```
## 5. 组合拼装
我们已经把每一部分都写好的，接下来我们将它们组合起来就行了：

```kotlin
    Row(modifier = modifier) {
        // 由于 Row 的缘故, 这里和下面进行了判断
        // 因为两个方向要显示的 swipeItem 位置不同
        if (!isEndToStart) {
            SwipeChild(isShowSwipe, swipeState, swipeContent)
        }
		...主体内容...
        if (isEndToStart) {
            SwipeChild(isShowSwipe, swipeState, swipeContent)
        }
    }
```
这里就可以看到我刚才说的用到两次了，因为在 Row 中时按我们写的顺序从左往右排的，而我们的侧拉组件又要在两侧显示，所以就只能如此了（不知道有没什么好的办法，可以教教我不）。
## 6. 结果测验
在前面我们已经把所有内容都讲完了（[完整代码](#index)在这），最后来测验一些，测验代码（调用它就行）：

```kotlin
@Composable
fun Main() {
    SwipeItem(
        modifier = Modifier
            .fillMaxWidth()
            .height(50.dp),
        swipeItemWidth = 20f,
        isShowSwipe = true,
        swipeDirection = SwipeDirection.STARTTOEND,
//        swipeDirection = SwipeDirection.ENDTOSTART,
        swipeContent = {
            Icon(
                imageVector = Icons.Default.Face,
                contentDescription = null
            )
        }) {
        Row {
            Text(
                text = "哈哈哈哈哈哈哈哈哈哈哈哈",
                modifier = Modifier.background(Color.Red),
                fontSize = 30.sp
            )
        }
    }
}
```
效果展示：
从右往左拉：
![img](./assets/post_img/07a1ce5d6038520b01bb450ff6a7422d_MD5.gif)
从左往右拉：
![img](./assets/post_img/43755180ca6ac71ece0343e53847a912_MD5.gif)
点击侧拉组件隐藏：
![img](./assets/post_img/9a2a56d031d3e5995f124124d6159bf0_MD5.gif)

---

# 三、<span id="index">完整代码</span>
这里放上核心代码，里面带有注释来解释：
```kotlin
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.IntOffset
import kotlinx.coroutines.launch

/**
 * @Description: 侧拉滑动组件
 * @Param:
 * @param modifier 没啥好说的
 * @param swipeItemWidth 侧拉组件的宽度
 * @param isShowSwipe 判断是否显示
 * @param swipeDirection 判断侧拉方向
 * @param swipeContent 侧拉组件的内容
 * @param content 主题内容
 * @return:
 */
@OptIn(ExperimentalMaterialApi::class, ExperimentalAnimationApi::class)
@Composable
fun SwipeItem(
    modifier: Modifier = Modifier,
    swipeItemWidth: Float,
    isShowSwipe: Boolean = true,
    swipeDirection: SwipeDirection = SwipeDirection.ENDTOSTART,
    swipeContent: @Composable () -> Unit,
    content: @Composable () -> Unit
) {
    // 记录一下滑动方向, 便于下面的判断
    val isEndToStart = swipeDirection == SwipeDirection.ENDTOSTART
    val swipeState = rememberSwipeableState(initialValue = false)
    // 滑动偏移量, 偏移量指 content 的左边的偏移
    val dx: Float = if (isEndToStart) {
        -swipeItemWidth
    } else {
        swipeItemWidth
    }
    // 偏移 dx 时显示, 两个方向不同, 所以上面对 dx 做判断
    val anchors = mapOf(dx to true, 0f to false)
    Row(modifier = modifier) {
        // 由于 Row 的缘故, 这里和下面进行了判断
        // 因为两个方向要显示的 swipeItem 位置不同
        if (!isEndToStart) {
            SwipeChild(isShowSwipe, swipeState, swipeContent)
        }
        Box(
            modifier = Modifier
//                .fillMaxWidth()
                // 这里要用 weight 才会有挤压的效果
                // 而且用 fillMaxWidth() 滑动组件会被遮挡
                .weight(1f)
                .offset {
                    IntOffset(
                        swipeState.offset.value.toInt(), 0
                    )
                }
                // swipeable() 是滑动组件的核心所在
                .swipeable(
                    state = swipeState,
                    anchors = anchors,
                    thresholds = { _, _ -> FractionalThreshold(1f) },
                    orientation = Orientation.Horizontal
                )
        ) {
            // 主体内容
            content()
        }
        if (isEndToStart) {
            SwipeChild(isShowSwipe, swipeState, swipeContent)
        }
    }
}

/**
 * @Description: 侧拉组件显示与隐藏
 * @Param:
 * @param isShowSwipe
 * @param swipeState
 * @param swipeContent
 * @return:
 */
@OptIn(ExperimentalMaterialApi::class, ExperimentalAnimationApi::class)
@Composable
private fun RowScope.SwipeChild(
    isShowSwipe: Boolean,
    swipeState: SwipeableState<Boolean>,
    swipeContent: @Composable () -> Unit
) {
    val scope = rememberCoroutineScope()
    // 这里用动画进行侧拉组件显示和隐藏
    AnimatedVisibility(visible = isShowSwipe && swipeState.currentValue) {
        Box(modifier = Modifier
            .align(alignment = Alignment.CenterVertically)
            .clickable {
                scope.launch {
                    swipeState.animateTo(false)
                }
            }) {
            swipeContent()
        }
    }
}

enum class SwipeDirection {
    STARTTOEND,
    ENDTOSTART
}

```

---
# 最后
文章就到这，希望对你有帮助，欢迎评论，拜拜！
