# AlignCompatFlex
Flutter库，可以在Row或Column的children中使用Align依然可以使它们能自适应高度或宽度

在Row或Column中可以使用`crossAxisAlignment`在交叉轴方向控制children的排列位置，假设在Row中把它设置成`CrossAxisAlignment.start`，即所有child都是靠上方排列对齐，但恰好有一个child需要居中对齐，首先想到的肯定是给这个child套了个Center或Align，像这样: 
```dart
Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
            Container(width: 30, height: 30, color: Colors.amberAccent),
            Expanded(child: Container(height: 80, color: Colors.blueAccent)),
            Align(child: Container(width: 15, height: 15, color: Colors.deepOrange)),
    ],
)
```
但很遗憾，运行起来后发现界面变成了这样
<br/>![1.1](https://upload-images.jianshu.io/upload_images/2384878-01b57d5c2c43cb24.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
<br/>而我想要的效果是这样
<br/>![1.2](https://upload-images.jianshu.io/upload_images/2384878-aaff3ac85e536e68.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
Row的高度应该是自适应的，取决于最高的那个子child(图1.2中间的那个蓝色子child)，但很显然由于Align的加入直接将Row的高度干到了最大。
<br/>不过其实稍微一想图1.1的结果是有道理的，Align的确需要尺寸定位无限大才能对它的child进行布局，它的parent也当然必须有明确的尺寸约束，所以要做到这个效果就必须对Row的源码动手脚。
<br/>查看Row的父类Flex继承自RenderObjectWidget，发现其createRenderObject方法返回的是`RenderFlex`，而RenderFlex继承自RenderBox，RenderBox继承自`RenderObject`。
```dart
class Flex extends MultiChildRenderObjectWidget {
  ...
  @override
  RenderFlex createRenderObject(BuildContext context) {
    return RenderFlex(...);
  }
}
class RenderFlex extends RenderBox {...}
abstract class RenderBox extends RenderObject {...}
```
RenderObject的这一套我们就非常熟悉了，所以直接看RenderFlex的`performLayout`干了啥
```dart
//flex.dart 
@override
  void performLayout() {
    ...
    double crossSize = 0.0;
    ...
    while (child != null) {
        ...
          //759行
          switch (_direction) {
            case Axis.horizontal:
              innerConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
              break;
          }
        child.layout(innerConstraints, parentUsesSize: true);
        crossSize = math.max(crossSize, _getCrossSize(child));
      }
    }
    ...
    //865行
    switch (_direction) {
      case Axis.horizontal:
        size = constraints.constrain(Size(idealSize, crossSize));
        break;
    }
  }
```
这个方法代码非常的多，直接通读会很难受，但好在关键点的代码非常的好找，可以看到759行会循环所有子child进行测量，同时把最大的子child高度记录在`crossSize`中，接着在865行通过crossSize确定自己的高度。
<br/>所以关键点就在child.layout，我们可以重写这个过程，在计算crossSize的时候把Align排除出去，只计算非Align类型的child，这样crossSize记录的就是除去Align以外最高的child。
然后重新测量child，非Align类型的child依然用原约束测量，而Align我们直接使用crossSize作为约束的maxHeight即可，当然最后不要忘了把size中height换成我们自己计算的crossSize。

<br/>要达成这样的效果我们需要写一个继承自Row或Column的子类，非常简单，完整代码请移步：https://github.com/qstumn/AlignCompatFlex

ps：本文flex.dart源码基于flutter 1.22.6版本
