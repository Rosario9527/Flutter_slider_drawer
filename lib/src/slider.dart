import 'package:flutter/material.dart';
import 'app_bar.dart';
import 'helper/slider_app_bar.dart';
import 'slider_bar.dart';
import 'slider_direction.dart';

/// SliderDrawer which have two [child] and [slider] parameter
///
///For Example :
///
/// Scaffold(
///         body: SliderDrawer(
///             appBar: SliderAppBar(
///                 appBarColor: Colors.white,
///                 title: Text(title,
///                     style: const TextStyle(
///                         fontSize: 22, fontWeight: FontWeight.w700))),
///             key: _key,
///             sliderOpenSize: 200,
///             slider: SliderView(
///               onItemClick: (title) {
///                 _key.currentState!.closeSlider();
///                 setState(() {
///                   this.title = title;
///                 });
///               },
///             ),
///             child: AuthorList()),
///       )
///
///
class SliderDrawer extends StatefulWidget {
  /// [Widget] which display when user open drawer
  ///
  final Widget slider;

  /// [Widget] main screen widget
  ///
  final Widget child;

  /// [int] you can changes sliderDrawer open/close animation times with this [animationDuration]
  /// parameter
  ///
  final int animationDuration;

  /// [double] you can change open drawer size by this parameter [sliderOpenSize]
  ///
  final double sliderOpenSize;

  ///[bool] if you set [false] then swipe to open feature disable.
  ///By Default it's true
  ///
  final bool isDraggable;

  ///[appBar] if you set [null] then it will not display app bar
  ///
  final Widget? appBar;

  /// The primary color of the button when the drawer button is in the down (pressed) state.
  /// The splash is represented as a circular overlay that appears above the
  /// [highlightColor] overlay. The splash overlay has a center point that matches
  /// the hit point of the user touch event. The splash overlay will expand to
  /// fill the button area if the touch is held for long enough time. If the splash
  /// color has transparency then the highlight and drawer button color will show through.
  ///
  /// Defaults to the Theme's splash color, [ThemeData.splashColor].
  ///
  final Color splashColor;

  ///[slideDirection] you can change slide direction by this parameter [slideDirection]
  ///There are three type of [SlideDirection]
  ///[SlideDirection.RIGHT_TO_LEFT]
  ///[SlideDirection.LEFT_TO_RIGHT]
  ///[SlideDirection.TOP_TO_BOTTOM]
  ///
  /// By default it's [SlideDirection.LEFT_TO_RIGHT]
  ///
  final SlideDirection slideDirection;

  /// [animationCurve]自动对齐时的Curve
  final Curve animationCurve;

  ///  [enableSliderDrag] 是否能在SliderMenu区域拖动body的部分
  final bool enableSliderDrag;

  /// [enableTapBodyClose] 是否启用点击body关闭SliderMenu
  final bool enableTapBodyClose;

  /// [dragRightPadX] 向右拖动到，距离最右的距离
  final double dragRightPadX;

  /// [dragLeftMinX] 向左拖动时，能到达的最远距离(允许负数)
  final double dragLeftMinX;

  /// [backgroudColor] 整个容器的背景色
  /// 在向右拖动时，到一定距离时会和Silder有间隙，这里可以看到背景色
  final Color backgroudColor;

  /// [foregroudMaxOpacity] 向右滑时，会根据滑动距离增加不透明度,用这个限制最大值。
  final double foregroudMaxOpacity;

  const SliderDrawer(
      {Key? key,
      required this.slider,
      required this.child,
      this.isDraggable = true,
      this.animationDuration = 400,
      this.sliderOpenSize = 230,
      this.splashColor = Colors.transparent,
      this.slideDirection = SlideDirection.LEFT_TO_RIGHT,
      this.appBar = const SliderAppBar(),
      this.animationCurve = Curves.linear,
      this.enableSliderDrag = false,
      this.enableTapBodyClose = false,
      this.dragRightPadX = 20.0,
      this.dragLeftMinX = -30.0,
      this.backgroudColor = Colors.white,
      this.foregroudMaxOpacity = 0.5})
      : super(key: key);

  @override
  SliderDrawerState createState() => SliderDrawerState();
}

class SliderDrawerState extends State<SliderDrawer>
    with TickerProviderStateMixin {
  double _maxWidth = 0.0;
  double _dragX = 0.0;
  Color _foregroundColor = Colors.black.withOpacity(0);

  late final double _dragMaxX;
  late final double _dragMinX;

  late AnimationController _controller;
  late Animation _animation;

  /// it's provide [animationController] for handle and lister drawer animation
  AnimationController? get animationController => _controller;

  /// Toggle drawer
  void toggle() {}

  _moveAlign({double? to}) {
    double end = 0.0;
    if (to == null) {
      if (_dragX > widget.sliderOpenSize / 2) {
        end = widget.sliderOpenSize;
      }
    } else {
      end = to;
    }

    _animation = Tween<double>(begin: _dragX, end: end).animate(
        CurvedAnimation(parent: _controller, curve: widget.animationCurve));
    _controller.reset();
    _controller.forward();
  }

  _calcForegroundColor() {
    var opacity = _dragX / widget.sliderOpenSize * widget.foregroudMaxOpacity;
    if (opacity > widget.foregroudMaxOpacity)
      opacity = widget.foregroudMaxOpacity;
    if (opacity < 0) opacity = 0.0;
    return Colors.black.withOpacity(opacity);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.animationDuration));
    _controller.addListener(() {
      _dragX = _animation.value;
      _foregroundColor = _calcForegroundColor();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color appBarColor = Colors.white;
    if (widget.appBar is SliderAppBar) {
      appBarColor = (widget.appBar as SliderAppBar).appBarColor;
    }
    return LayoutBuilder(builder: (context, constrain) {
      if (_maxWidth == 0.0) {
        _maxWidth = constrain.maxWidth;
        _initDragLimited();
      }
      return Container(
          decoration: BoxDecoration(color: widget.backgroudColor),
          foregroundDecoration: BoxDecoration(
            color: _foregroundColor,
          ),
          child: Stack(children: <Widget>[
            ///  Menu
            if (widget.enableSliderDrag)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                child: SliderBar(
                  slideDirection: widget.slideDirection,
                  sliderMenu: widget.slider,
                  sliderMenuOpenSize: widget.sliderOpenSize,
                ),
              )
            else
              SliderBar(
                slideDirection: widget.slideDirection,
                sliderMenu: widget.slider,
                sliderMenuOpenSize: widget.sliderOpenSize,
              ),

            //Child
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(_dragX, 0),
                  child: child,
                );
              },
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: _onTap,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.red,
                  child: Column(
                    children: <Widget>[
                      if (widget.appBar != null &&
                          widget.appBar is SliderAppBar)
                        SAppBar(
                          slideDirection: widget.slideDirection,
                          onTap: () => toggle(),
                          animationController: _controller,
                          splashColor: widget.splashColor,
                          sliderAppBar: widget.appBar as SliderAppBar,
                        ),
                      if (widget.appBar != null &&
                          widget.appBar is! SliderAppBar)
                        widget.appBar!,
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ),
            ),
          ]));
    });
  }

  _initDragLimited() {
    _dragMaxX = _maxWidth - widget.dragRightPadX;
    _dragMinX = widget.dragLeftMinX;
  }

  _onTap() {
    if (_controller.isCompleted && _dragX >= widget.sliderOpenSize) {
      _moveAlign(to: 0.0);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails detail) {
    if (!widget.isDraggable) return;
    _moveAlign();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails detail) {
    if (!widget.isDraggable) return;
    var x = _dragX + detail.delta.dx;
    if (x > _dragMaxX) x = _dragMaxX;
    if (x < _dragMinX) x = _dragMinX;
    if (x != _dragX) {
      setState(() {
        _dragX = x;
        _foregroundColor = _calcForegroundColor();
      });
    }
  }
}
