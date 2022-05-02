library flutter_vcard;

import 'dart:math';
import 'package:flutter/material.dart';

typedef NextCallback(int index);
typedef PreviousCallback(int index);
typedef IndexChangeCallback(int index);
typedef EndCallback();

class VCardView extends StatefulWidget {
  /// 卡片尺寸
  final Size size;

  /// 缩放比例，默认 0.03
  final double expandScales;

  /// 子项数量
  final int itemCount;

  /// 构建子项布局
  final IndexedWidgetBuilder itemBuild;

  /// 滑动速度（非零，默认1.3）
  final double slideSpeed;

  /// 控制器
  final VCardController? controller;

  /// 下一页回调
  final NextCallback? nextCallback;

  /// 上一页回调
  final PreviousCallback? previousCallback;

  /// 下标改变的回调
  final IndexChangeCallback? indexChangeCallback;

  /// 最后一个结束的回调
  final EndCallback? endCallback;

  VCardView({
    Key? key,
    required this.size,
    required this.itemCount,
    required this.itemBuild,
    this.expandScales = 0.03,
    this.slideSpeed = 1.3,
    this.controller,
    this.nextCallback,
    this.previousCallback,
    this.indexChangeCallback,
    this.endCallback,
  }) : super(key: key);

  @override
  State<VCardView> createState() => _VCardViewState();
}

class _VCardViewState extends State<VCardView> with TickerProviderStateMixin {
  //  最前面卡片的索引
  int _frontCardIndex = 0;
  int get frontCardIndex => _frontCardIndex;
  // 滑动时的偏移量
  double _pageOffsetY = 0.0;
  // 将要进到下一页
  bool _willNext = false;
  // 将要进到上一页
  bool _willPrevious = false;
  // 动画控制器
  late AnimationController _animationController;
  // 动画
  late Animation<double> _animation;

  // 滑动的动画
  Animation<double> _slideAnimation(
      AnimationController controller, double begin,
      {double end = 0}) {
    // double end = 0;
    if (_pageOffsetY < 0) {
      end = (_pageOffsetY.abs() < widget.size.height * 0.5)
          ? 0
          : -widget.size.height;
    } else if (_pageOffsetY > 0) {
      end = (_pageOffsetY.abs() < widget.size.height * 0.5)
          ? 0
          : widget.size.height;
    }
    return _animationController.drive(CurveTween(curve: Curves.easeIn)).drive(
        Tween<double>(begin: _pageOffsetY, end: end))
      ..addListener(() {
        _pageOffsetY = min(
            widget.size.height, (max(-widget.size.height, _animation.value)));
        _setPageOffsetYLimit();

        // 下一页&上一页
        if (_pageOffsetY < 0) {
          _willNext = true;
          _willPrevious = false;
        } else if (_pageOffsetY > 0) {
          _willNext = false;
          _willPrevious = true;
        } else {
          _willNext = false;
          _willPrevious = false;
        }
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pageOffsetY = 0;

          // 进入下一页
          if (_willNext) {
            _frontCardIndex++;
            // 下标最大值
            if (_frontCardIndex >= widget.itemCount) {
              _frontCardIndex = widget.itemCount - 1;
            }
            // 结束了的回调
            if (_frontCardIndex >= widget.itemCount - 1) {
              if (widget.endCallback != null &&
                  widget.endCallback is Function) {
                widget.endCallback!();
              }
            }
            // 下一页回调
            if (widget.nextCallback != null &&
                widget.nextCallback is Function) {
              widget.nextCallback!(_frontCardIndex);
            }
          }

          // 进入上一页
          if (_willPrevious) {
            _frontCardIndex--;
            // 下标最小值
            if (_frontCardIndex < 0) {
              _frontCardIndex = 0;
            }
            // 上一页回调
            if (widget.previousCallback != null &&
                widget.previousCallback is Function) {
              widget.previousCallback!(_frontCardIndex);
            }
          }

          // 下标改变回调
          if ((_willNext || _willPrevious) &&
              widget.indexChangeCallback != null &&
              widget.indexChangeCallback is Function) {
            widget.indexChangeCallback!(_frontCardIndex);
          }

          // 清空下一页&上一页状态
          _willNext = false;
          _willPrevious = false;
          setState(() {});
        }
      });
  }

  // 开始滑动的动画
  _startSlideAnimation(Animation<double> animation) {
    _animation = animation;
    _animationController.reset();
    _animationController.forward();
  }

  // 垂直方向停止滑动事件，开始执行动画
  _onEndPanVerticalAnimation(DragEndDetails details) {
    _animation = _slideAnimation(_animationController, _pageOffsetY);
    _startSlideAnimation(_animation);
  }

  // 第 0 页，超过屏幕，在上部的，不缩放，初始透明度 0
  Widget _card0() {
    if (_frontCardIndex < 1) {
      return SizedBox();
    }
    int index =
        (_frontCardIndex > 1 && (_frontCardIndex - 1) < widget.itemCount)
            ? (_frontCardIndex - 1)
            : 0;

    double offsetY = -widget.size.height;
    if (_pageOffsetY < 0) {
    } else if (_pageOffsetY > 0) {
      offsetY = -widget.size.height -
          2 * widget.expandScales * widget.size.height / 2 +
          _pageOffsetY;
    }

    return TransformView(
      opacity: (_pageOffsetY > 0) ? _pageOffsetY / widget.size.height : 0,
      offset: Offset(0, offsetY),
      size: widget.size,
      child: widget.itemBuild(context, index),
    );
  }

  // 第 1 页，刚开始显示的页面，不缩放，初始透明度 1
  Widget _card1() {
    if (_frontCardIndex > widget.itemCount - 1) {
      return SizedBox();
    }
    int index = _frontCardIndex < widget.itemCount ? _frontCardIndex : 0;
    double scales = 1 - 0 * widget.expandScales;
    double offsetY = 0 - 2 * widget.expandScales * widget.size.height / 2;

    double a = (_pageOffsetY / widget.size.height);
    scales = scales - a * widget.expandScales;
    if (_pageOffsetY < 0) {
      offsetY = offsetY + _pageOffsetY;
    } else if (_pageOffsetY > 0) {
      offsetY = offsetY + _pageOffsetY * a * widget.expandScales;
    }

    return TransformView(
      opacity: min(1.0, max(0.0, 1.0 + _pageOffsetY / widget.size.height)),
      offset: Offset(0, offsetY),
      size: widget.size,
      scale: scales,
      child: widget.itemBuild(context, index),
    );
  }

  // 第 2 页，第一页的后面一页，初始缩放 1 * widget.expandScales ，偏移
  Widget _card2() {
    if (_frontCardIndex > widget.itemCount - 2) {
      return SizedBox();
    }
    int index =
        (_frontCardIndex + 1) < widget.itemCount ? (_frontCardIndex + 1) : 1;
    double scales = 1 - 1 * widget.expandScales;
    double offsetY = (1 - scales) / 2 * widget.size.height -
        widget.expandScales * widget.size.height / 2;

    double a = (_pageOffsetY / widget.size.height);
    scales = scales - a * widget.expandScales;
    if (_pageOffsetY < 0) {
      offsetY = offsetY - _pageOffsetY * a * widget.expandScales;
    } else if (_pageOffsetY > 0) {
      offsetY = offsetY + _pageOffsetY * a * widget.expandScales;
    }

    return TransformView(
      opacity: 1.0,
      offset: Offset(0.0, offsetY),
      scale: scales,
      size: widget.size,
      child: widget.itemBuild(context, index),
    );
  }

  // 第 3 页，第二页的后面一页，初始缩放 2 * widget.expandScales ，偏移
  Widget _card3() {
    if (_frontCardIndex > widget.itemCount - 3) {
      return SizedBox();
    }
    int index =
        (_frontCardIndex + 2) < widget.itemCount ? (_frontCardIndex + 2) : 2;
    double scales = 1 - 2 * widget.expandScales;
    double offsetY = (1 - scales) / 2 * widget.size.height;

    double a = (_pageOffsetY / widget.size.height);
    scales = scales - a * widget.expandScales;
    if (_pageOffsetY < 0) {
      offsetY = offsetY - _pageOffsetY * a * widget.expandScales;
    } else if (_pageOffsetY > 0) {
      // offsetY = offsetY + _pageOffsetY * a * widget.expandScales;
    }

    return TransformView(
      opacity: 1.0,
      scale: scales,
      offset: Offset(0, offsetY),
      size: widget.size,
      child: widget.itemBuild(context, index),
    );
  }

  // 第 4 页，第三页的后面一页，初始缩放 3 * widget.expandScales ，偏移和3一样
  Widget _card4() {
    if (_frontCardIndex > widget.itemCount - 4) {
      return SizedBox();
    }
    int index =
        (_frontCardIndex + 3) < widget.itemCount ? (_frontCardIndex + 3) : 3;
    double scales = 1 - 3 * widget.expandScales;
    double offsetY = (1 - scales) / 2 * widget.size.height - 0;

    double a = (_pageOffsetY / widget.size.height);
    scales = scales - a * widget.expandScales;
    if (_pageOffsetY < 0) {
      offsetY = offsetY - _pageOffsetY * a * widget.expandScales / 2;
    } else if (_pageOffsetY > 0) {
      //   // offsetY = offsetY + _pageOffsetY * a * widget.expandScales;
    }

    return TransformView(
      opacity: _pageOffsetY >= 0 ? 0.0 : 1.0,
      scale: scales,
      offset: Offset(0, offsetY),
      size: widget.size,
      child: widget.itemBuild(context, index),
    );
  }

  // 设置 pageOffsetY 的各种情况下 值的 范围
  _setPageOffsetYLimit() {
    // 当第一页时下拉是往前看一页，此时是没有上一页的，故设置不能超过翻页的标准
    if (_frontCardIndex == 0 && _pageOffsetY > 0) {
      _pageOffsetY = min(_pageOffsetY, widget.size.height / 2 - 50);
    }
    // 当最后一页时上拉是看下一页，此时是没有下一页的，故设置不能超过翻页的标准
    if (_frontCardIndex == widget.itemCount - 1 && _pageOffsetY < 0) {
      _pageOffsetY = max(_pageOffsetY, -widget.size.height / 2 + 50);
    }
    // 最小值
    if (_pageOffsetY <= -widget.size.height) {
      _pageOffsetY = -widget.size.height;
    }
    // 最大值
    if (_pageOffsetY >= widget.size.height) {
      _pageOffsetY = widget.size.height;
    }
  }

  Widget _gestureView() {
    return SizedBox.expand(
      child: GestureDetector(
        // 垂直滑动
        onVerticalDragDown: (details) {
          // print('垂直--->down--->$details');
          _animationController.stop();
        },
        onVerticalDragStart: (details) {
          // print('垂直--->start--->${_pageOffsetY}');
        },
        onVerticalDragUpdate: (details) {
          _pageOffsetY += (details.delta.dy * widget.slideSpeed);
          _setPageOffsetYLimit();
          setState(() {});
          // print(
          //     '垂直--->update---${widget.size}-->$details-->primaryDelta:${details.primaryDelta}-->_pageOffsetY:${_pageOffsetY}');
        },
        onVerticalDragEnd: (details) {
          // print('垂直--->end--->${details.primaryVelocity}-->$_pageOffsetY');
          _onEndPanVerticalAnimation(details);
        },
        onVerticalDragCancel: () {
          // print('垂直--->cancel--->');
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    // 绑定控制器
    if (widget.controller != null && widget.controller is VCardController) {
      widget.controller!.bindState(this);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    if (widget.controller != null) {
      widget.controller!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.size,
      child: Stack(
        children: [
          _card4(),
          _card3(),
          _card2(),
          _card1(),
          _card0(),
          _gestureView(),
        ],
      ),
    );
  }
}

class VCardController {
  _VCardViewState? state;

  int get index => state?.frontCardIndex ?? 0;

  void bindState(_VCardViewState state) {
    this.state = state;
  }

  // dispose
  void dispose() {
    state = null;
  }

  // 下一个
  void next() {
    state!._startSlideAnimation(
      state!._slideAnimation(state!._animationController, 0,
          end: -state!.widget.size.height),
    );
  }

  // 上一个
  void previous() {
    state!._startSlideAnimation(
      state!._slideAnimation(state!._animationController, 0,
          end: state!.widget.size.height),
    );
  }
}

/// 变化视图，可改缩放、透明度、偏移量
class TransformView extends StatelessWidget {
  final Size size;
  final double? opacity;
  final double? scale;
  final Offset? offset;
  final Widget child;
  const TransformView({
    Key? key,
    required this.size,
    required this.child,
    this.opacity,
    this.scale,
    this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tmpWidget = SizedBox.fromSize(
      size: size,
      child: child,
    );

    if (scale != null) {
      tmpWidget = Transform.scale(
        scale: scale!,
        child: tmpWidget,
      );
    }
    if (offset != null) {
      tmpWidget = Transform.translate(
        offset: offset!,
        child: tmpWidget,
      );
    }
    if (opacity != null) {
      tmpWidget = Opacity(
        opacity: opacity!,
        child: tmpWidget,
      );
    }
    return tmpWidget;
  }
}
