---
title: Compose Text + Canvas 写个验证码
categories: [ blog ]
tags: [ blog Android ]
---
# 前言
在搞登录功能时，想弄个登录验证码，在网上溜了一圈好像还没有用 Compose 写过的（可能是没搜到），既然没有就自己搞一个吧。
大家如果没时间或者基础好可以直接去[完整代码](#index) 看核心代码，因为实现比较简单，也比较重复。当然我也是很欢迎你阅读我的文章和我一步步学习的。

---

# 一、工具选择
网上大部分都是用 paint 来实现的，但是在 Compose 里 paint 的属性好像有所减少，就比如 textSkewX 就没有（下为 Compose ）：![img](./assets/post_img/88458b38fa1061e38b9b6b9f6b1fd0c3_MD5.png)
![img](./assets/post_img/d2baed79c7520c8d2ca287894a120864_MD5.png)
既然这样用 paint 就不大好了。最后想到，验证码一般包括字母和数字，那就直接用最简单的 Text 加 canvas 来呗。

---
# 二、基本思想
验证码最重要的是随机性，那我们如何做到随机呢？这不是很简单吗，用 Random 啊。那验证码的样式如何做到不同呢？这不是很简单吗，用 Random + 属性啊。所以我们只要罗列 Text 的属性，配上 Random 就能得到验证码的基本样式了：
![img](./assets/post_img/0de08cf989759b5cac994ad21c0dd895_MD5.png)
那上面说到的 canvas 拿来干嘛呢，它其实是用来画干扰线的，最后的效果是这样的（应该还行）：
![img](./assets/post_img/d34d48f12c27fb34a698d09de735871d_MD5.png)
可能有更好的想法，但是我不会。下面我们来举一例讲讲具体实现。

---
# 三、具体实现
## 0、参数解释
这里先放上最后实现验证码所需要的参数并解释一下，便于大家后面的阅读：

```kotlin
@RequiresApi(Build.VERSION_CODES.Q)
@OptIn(ExperimentalUnitApi::class)
@Composable
fun VerifyCode(
    // 宽高不用解释
    width: Dp,
    height: Dp,
    // 距离左上角的的偏移量, 用于定位
    topLeft: DpOffset = DpOffset.Zero,
    // 验证码的数量
    codeNum: Int = 4,
    // 干扰线的数量
    disturbLineNum: Int = 10,
    // 用于保存验证码, 用于用户输入时进行验证
    viewModel: MyViewModel
) {}
```

## 1、验证内容
最先要实现的当然是的要验证的东西啦，像这样：

```kotlin
private val codeList = listOf(
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
        "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
        "u", "v", "w", "x", "y", "z",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
        "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z"
    )
```
我们用数字和字母进行验证，在后面我会随机挑选 codeNum 个用来作为验证码。
## 2、Text 设置
根据上面所说的 Random + 属性的想法。我们先得到 Text 的所有属性：

```kotlin
Text(
    text = ,
    modifier = ,
    color = ,
    fontSize = ,
    fontStyle = ,
    fontWeight = ,
    fontFamily = ,
    textDecoration = ,
    textAlign = ,
    letterSpacing = ,
    lineHeight = ,
    maxLines =,
    onTextLayout =,
    style =,
)
```
并且罗列所有将要赋予属性的值（这里以 fontFamily 为例）：

```kotlin
    private val fontFamilyList = listOf(
        FontFamily.Default,
        FontFamily.Cursive,
        FontFamily.Monospace,
        FontFamily.SansSerif,
        FontFamily.Serif
    )
```
下面是各个用到的属性的所有值，大家如果想看可以前往[完整代码](#index)先偷窥一下再回头来继续学习。
![img](./assets/post_img/c82782c80ba44814f50e8e7db2ce1fb9_MD5.png)
加上 Random ：

```kotlin
    private fun <T> List<T>.getRandom() = this[Random.nextInt(this.size)]
//    shuffled() 函数返回⼀个包含了以随机顺序排序的集合元素的新的 List
//    private fun <T>  List<T>.getRandom() : T = this.shuffled().take(1)[0]
```
这里用了 kotlin 的扩展函数（用起来真的爽），有两种写法大家自选。
最后的得到这样的结果：

```kotlin
Text(
    text = Code.getCode(),
    modifier = Modifier
        .width(width / codeNum)
        .height(height)
        .offset(topLeft.x + dx, topLeft.y),
    color = Code.getColor(),
    // fontSize 需要的是 TextUnit 需要将 dp 转为 sp
    // 用 min() 保证字符都能被看见
    fontSize = Code.getTextUnit(
        minDp = min(width / codeNum / 2, height),
        maxDp = min(width / codeNum, height)
    ),
    fontStyle = Code.getFontStyle(),
    fontWeight = Code.getFontWeight(),
    fontFamily = Code.getFontFamily(),
    textDecoration = Code.getTextDecoration(),
    textAlign = Code.getTextAlign(),
    // 由于我们 Text 里只有一个字符, 有的属性就没必要了
    // letterSpacing = ,
    // lineHeight = ,
    // maxLines =,
    // onTextLayout =,
    // style =,
)
```
大家一定要注意加上 topLeft. x 和 topLeft. y，验证码不能老待在左上角吧。这里的 Code 是一个单例类：
![img](./assets/post_img/5662eb121847b5f088ed2916c80aa4c3_MD5.png)
用于封装方法便于使用。
最后还要加上：

```kotlin
repeat(codeNum) {}
```
我们需要 codeNum 个字符，而且每次应该从 Code.getCode () 的到一个字符，不然的话所有字符的样式都是相同的。
到这我们 Text 就实现好了。
## 3、干扰线的实现
先放代码：

```kotlin
repeat(disturbLineNum) {
    val startOffset = Code.getLineOffset(
        minDpX = topLeft.x,
        maxDpX = topLeft.x + width,
        minDpY = topLeft.y,
        maxDpY = topLeft.y + height
    )
    
    val endOffset = Code.getLineOffset(
        minDpX = topLeft.x,
        maxDpX = topLeft.x + width,
        minDpY = topLeft.y,
        maxDpY = topLeft.y + height
    )
    
    val strokeWidth = Code.getStrokeWidth(height / 100, height / 40)
    Canvas(
        modifier = Modifier
            .width(width)
            .height(height)
    ) {
        // repeat 放在这, 对于每一条线 startOffset 和 endOffset 是一样的
        // repeat 多少次都只有一条线, 所以我们往外提
        // repeat(disturbLineNum)
        drawLine(
        // 这里两种都行, 我采用 brush
        // color = Code.getColor(),
            brush = Brush.linearGradient(
                Code.getColorList()
            ),
            start = startOffset,
            end = endOffset,
            strokeWidth = strokeWidth,
            cap = Code.getCap(),
        )
    }
}
```
这里我们首先得到起点和终点的位置，之后 drawLine 就轻而易举了。这里面的注释大家还是要注意的，和 Text 一样 topLeft. x 和 topLeft. y 不能忘，不然要怎么干扰 Text 呢。还有一点使用时 disturbLineNum 千万不要设置太大，不然你就是为难用户：
![img](./assets/post_img/6e758bd5cc1c95be7eaa8af59a8b2158_MD5.png)
这验证码是怕人看见了吗？

## 4、Code 单例类中的注意点
在 getColor () 中的不透明度不能设置太小（我直接不设置），显示的不是很清楚，比如：
![img](./assets/post_img/255bb51014ed7d309a4a8b53fc93c9be_MD5.png)
看的清吗？(好像可以哦)
在 getColorList () 里面，random 的下限一定要大于 1，不然：
![img](./assets/post_img/1140062832b6b8a94eec51f5878e259e_MD5.png)
红红的可怕吗？
这里是因为 Brush.linearGradient () 要求要有两种以上的颜色，不然和 Color 纯色有什么区别。
对 Code 单例类好奇，可以先去[完整代码](#index) 看看再回头来继续学习，其实也差不多结束了。
另外，在 Code 单例类里面的 dp 、sp 、px 的转换大家可以学习一下，在此之前我还不会呢。
## 5、初步测试
到这里我们已经可以得到验证码的样子了，只是还没有功能，我们下一步再实现，先来测试一下传参之后能否使用：
![img](./assets/post_img/06f83fe9c258d740a582d26e58040934_MD5.png)
很明显是没什么问题嘛，而且验证码还这么好看（WDBMNUM 1）。接着我们实现功能，毕竟验证码再好看也不是拿来看的嘛。
## 6、功能实现
要实现验证功能我们先要保存验证码，我们可以用 ViewModel 进行储存随机生成的验证码，随机生成的验证码要连成字符串，这样做：

```kotlin
		...省略代码...
	var code = ""
	repeat(codeNum) {
		val oneCode = Code.getCode()
		code += oneCode
		...省略代码...
	}
```
然后进行保存：

```kotlin
	...省略代码...
	// 将 code 转为小写, 以免一些大小写相似的字母导致用户输入错误
	viewModel.setCode(code = code.lowercase())
	...省略代码...
```
ViewModel 代码，比较简单：
```kotlin
class MyViewModel : ViewModel() {
    private var verifyCode by mutableStateOf("")
    fun setCode(code: String) {
        verifyCode = code
    }
    fun verify(input: String) = input.lowercase() == verifyCode
}
```
 verify () 用于验证。
 验证使用：

```kotlin
@RequiresApi(Build.VERSION_CODES.Q)
@Composable
fun Main(viewModel: MyViewModel) {
    Column {
        var text by remember {
            mutableStateOf("")
        }
        val context = LocalContext.current
        Row(
            Modifier
                .fillMaxWidth()
                .height(50.dp)
        ) {
            TextField(
                value = text,
                onValueChange = {
                    text = it
                },
                Modifier.weight(1f)
            )
            VerifyCode(
                width = 150.dp,
                height = 50.dp,
                topLeft = DpOffset(0.dp, 0.dp),
                codeNum = 4,
                disturbLineNum = 20,
                viewModel = viewModel
            )
        }
        Button(onClick = {
            if (viewModel.verify(text)) {
                Toast.makeText(context, "输入正确", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(context, "输入错误", Toast.LENGTH_SHORT).show()
            }
        }) {
            Text(text = "点我点我")
        }
    }
}
```
viewModel 在 activity 中构建后传入，在使用 TextField 我遇到过输入不能显示的问题，有兴趣可以移步 [Compose | TextField 无法显示输入内容](https://blog.csdn.net/WdbM_/article/details/123968236)看看，最好可以帮我解答一下，哈哈。看看我们的结果吧：
![img](./assets/post_img/23e0aaef53ccb2a96be81d808e9fd634_MD5.gif)
最后还有一个功能，就是我们平常都能看到点击验证码会给一个新的验证码。这要怎么实现呢？这不是很简单吗，利用 Compose 的响应式编程啊，像这样：
![img](./assets/post_img/d38efc3d34acf2a01fe9c488bee80fa5_MD5.png)
和点击有关的加上括号一共也就 7 行，这么短能实现吗，我们看看结果：
![img](./assets/post_img/eef6307e24ce460bf62742c774e842cf_MD5.gif)
敢放出来当然能实现啦。这里要注意最后面的 flag 虽然像旗一样插在那什么都没干，但是我们不能删去它，它就是响应式编程的精髓，当程序检测到它变化时就会进行重绘。这里的 remember 和 mutableStateOf 要是不懂可以看看我另一篇文章 [Compose | remember、mutableStateOf的使用](https://blog.csdn.net/WdbM_/article/details/123922729)比较基础，要是写的不好也请指教。

到这我们功能也实现啦。

---
# 四、<span id="index">完整代码</span>
这里就放一下核心的代码，就不往 Github 上放了：

```kotlin
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle.Companion.Italic
import androidx.compose.ui.text.font.FontStyle.Companion.Normal
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.*
import com.glintcatcher.mytest.MyViewModel
import kotlin.random.Random

@RequiresApi(Build.VERSION_CODES.Q)
@OptIn(ExperimentalUnitApi::class)
@Composable
fun VerifyCode(
    // 宽高不用解释
    width: Dp,
    height: Dp,
    // 距离左上角的的偏移量, 用于定位
    topLeft: DpOffset = DpOffset.Zero,
    // 验证码的数量
    codeNum: Int = 4,
    // 干扰线的数量
    disturbLineNum: Int = 10,
    // 用于保存验证码, 用于用户输入时进行验证
    viewModel: MyViewModel
) {
    var flag by remember {
        mutableStateOf(-1)
    }
    Box(
        modifier = Modifier
            .width(width)
            .height(height)
            .offset(topLeft.x, topLeft.y)
            .clickable {
                flag = -flag
            }
    ) {
        // 用于响应式编程,重绘验证码
        flag
        var dx = 0.dp
        var code = ""
        repeat(codeNum) {
            // 得到单个字符, 不能直接得到 codeNum 个字符, 不然样式是一样的
            val oneCode = Code.getCode()
            code += oneCode
            Text(
                text = oneCode,
                modifier = Modifier
                    .width(width / codeNum)
                    .height(height)
                    .offset(topLeft.x + dx, topLeft.y),
                color = Code.getColor(),
                // fontSize 需要的是 TextUnit 需要将 dp 转为 sp
                // 用 min() 保证字符都能被看见
                fontSize = Code.getTextUnit(
                    minDp = min(width / codeNum / 2, height),
                    maxDp = min(width / codeNum, height)
                ),
                fontStyle = Code.getFontStyle(),
                fontWeight = Code.getFontWeight(),
                fontFamily = Code.getFontFamily(),
                textDecoration = Code.getTextDecoration(),
                textAlign = Code.getTextAlign(),
                // 由于我们 Text 里只有一个字符, 有的属性就没必要了
//                letterSpacing = ,
//                lineHeight = ,
//                maxLines =,
//                onTextLayout =,
//                style =,
            )
            // dx 加上 Text 的宽度防止堆叠
            dx += width / codeNum
        }

        // 将 code 转为小写, 以免一些大小写相似的字母导致用户输入错误
        viewModel.setCode(code = code.lowercase())

        repeat(disturbLineNum) {
            val startOffset = Code.getLineOffset(
                minDpX = topLeft.x,
                maxDpX = topLeft.x + width,
                minDpY = topLeft.y,
                maxDpY = topLeft.y + height
            )

            val endOffset = Code.getLineOffset(
                minDpX = topLeft.x,
                maxDpX = topLeft.x + width,
                minDpY = topLeft.y,
                maxDpY = topLeft.y + height
            )

            val strokeWidth = Code.getStrokeWidth(height / 100, height / 40)
            Canvas(
                modifier = Modifier
                    .width(width)
                    .height(height)
            ) {
                // repeat 放在这, 对于每一条线 startOffset 和 endOffset 是一样的
                // repeat 多少次都只有一条线, 所以我们往外提
//            repeat(disturbLineNum)
                drawLine(
                    // 这里两种都行, 我采用 brush
//                color = Code.getColor(),
                    brush = Brush.linearGradient(
                        Code.getColorList()
                    ),
                    start = startOffset,
                    end = endOffset,
                    strokeWidth = strokeWidth,
                    cap = Code.getCap(),
                )
            }
        }
    }
}

object Code {
    private val codeList = listOf(
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
        "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
        "u", "v", "w", "x", "y", "z",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
        "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z"
    )

    @RequiresApi(Build.VERSION_CODES.Q)
    private val fontStyleList = listOf(
        Normal,
        Italic
    )

    private val fontWeightList = listOf(
        FontWeight.Black,
        FontWeight.Bold,
        FontWeight.ExtraBold,
        FontWeight.ExtraLight,
        FontWeight.Light,
        FontWeight.Medium,
        FontWeight.Normal,
        FontWeight.SemiBold,
        FontWeight.Thin,
        FontWeight.W100,
        FontWeight.W200,
        FontWeight.W300,
        FontWeight.W400,
        FontWeight.W500,
        FontWeight.W600,
        FontWeight.W700,
        FontWeight.W800,
        FontWeight.W900
    )

    private val fontFamilyList = listOf(
        FontFamily.Default,
        FontFamily.Cursive,
        FontFamily.Monospace,
        FontFamily.SansSerif,
        FontFamily.Serif
    )

    private val textDecorationList = listOf(
        TextDecoration.None,
        TextDecoration.LineThrough,
        TextDecoration.Underline
    )

    private val textAlignList = listOf(
        TextAlign.Center,
        TextAlign.Start,
        TextAlign.End,
        TextAlign.Justify,
        TextAlign.Left,
        TextAlign.Right
    )

    private val capList = listOf(
        StrokeCap.Butt,
        StrokeCap.Round,
        StrokeCap.Square
    )

    private fun <T> List<T>.getRandom() = this[Random.nextInt(this.size)]
//    shuffled() 函数返回⼀个包含了以随机顺序排序的集合元素的新的 List
//    private fun <T>  List<T>.getRandom() : T = this.shuffled().take(1)[0]

    fun getCode(): String = codeList.getRandom()

    @RequiresApi(Build.VERSION_CODES.Q)
    fun getFontStyle() = fontStyleList.getRandom()

    fun getFontWeight() = fontWeightList.getRandom()

    fun getFontFamily() = fontFamilyList.getRandom()

    fun getTextDecoration() = textDecorationList.getRandom()

    fun getTextAlign() = textAlignList.getRandom()

    fun getColor() = Color(
        red = Random.nextInt(256),
        green = Random.nextInt(256),
        blue = Random.nextInt(256),
        // 不透明度小的时候显示的不是很清楚, 所以就舍弃掉吧
//        alpha = Random.nextInt(256)
    )

    fun getColorList(): ArrayList<Color> {
        val colorList = arrayListOf<Color>()
        // 最小值要是 2, 如果 colorList 的 size = 1 会报错
        repeat(Random.nextInt(2, 11)) {
            colorList.add(getColor())
        }
        return colorList
    }

    fun getCap() = capList.getRandom()

    @Composable
    fun getTextUnit(minDp: Dp, maxDp: Dp) = with(LocalDensity.current) {
        val min = minDp.roundToPx()
        val max = maxDp.roundToPx()
        Random.nextInt(min, max + 1).toSp()
    }

    @Composable
    fun getLineOffset(minDpX: Dp, maxDpX: Dp, minDpY: Dp, maxDpY: Dp) =
        with(LocalDensity.current) {
            val minX = minDpX.roundToPx()
            val maxX = maxDpX.roundToPx()
            val minY = minDpY.roundToPx()
            val maxY = maxDpY.roundToPx()
            Offset(
                Random.nextInt(minX, maxX + 1).toFloat(),
                Random.nextInt(minY, maxY + 1).toFloat()
            )
        }

    @Composable
    fun getStrokeWidth(min: Dp, max: Dp) = with(LocalDensity.current) {
        val min = min.roundToPx()
        val max = max.roundToPx()
        Random.nextInt(min, max + 1).toFloat()
    }
}
```
---
# 最后
文章就到这，希望对你有帮助，欢迎评论，拜拜！
