import 'package:flutter/widgets.dart';

class SizedBuilder extends StatefulWidget {
  /// 需要计算大小的子组件
  final Widget measuredChild;

  /// 约束轴，指定在哪个轴上进行约束
  final Axis constrainedAxis;

  /// 构建器回调函数
  /// [context] BuildContext
  /// [size] 计算出的组件大小
  /// [widget] 原始子组件
  final Widget Function(BuildContext context, Size size, Widget widget) builder;

  const SizedBuilder(
      {super.key,
      required this.measuredChild,
      this.constrainedAxis = Axis.horizontal,
      required this.builder});

  @override
  State<SizedBuilder> createState() => _SizedBuilderState();
}

class _SizedBuilderState extends State<SizedBuilder> {
  Size? _widgetSize;
  final GlobalKey _sizeKey = GlobalKey();
  Object? _lastSubjectHash;

  @override
  void initState() {
    super.initState();
    _lastSubjectHash = widget.measuredChild.hashCode;
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateSize());
  }

  @override
  void didUpdateWidget(SizedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentSubjectHash = widget.measuredChild.hashCode;
    final needsRecalculation =
        oldWidget.measuredChild != widget.measuredChild ||
            oldWidget.constrainedAxis != widget.constrainedAxis ||
            _lastSubjectHash != currentSubjectHash;

    _lastSubjectHash = currentSubjectHash;

    if (needsRecalculation) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculateSize());
    }
  }

  void _calculateSize() {
    if (!mounted) return;
    final RenderBox? renderBox =
        _sizeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      setState(() => _widgetSize = renderBox.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 同时渲染测量组件（不可见）和实际构建的组件
    return Stack(
      children: [
        // 隐藏的测量组件（用于实时计算subject尺寸）
        Offstage(offstage: true, child: _buildMeasuredWidget()),
        // 实际展示的组件
        if (_widgetSize != null)
          widget.builder(context, _widgetSize!, widget.measuredChild)
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildMeasuredWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: _getConstraintsForAxis(constraints),
          // 使用UniqueKey强制每次重建测量组件，确保尺寸刷新
          child: Container(
            key: UniqueKey(),
            child: SizeChangedNotifier(
              child: widget.measuredChild,
              onSizeChanged: (newSize) {
                // 监听subject尺寸变化，实时更新
                if (mounted) {
                  setState(() => _widgetSize = newSize);
                }
              },
            ),
          ),
        );
      },
    );
  }

  BoxConstraints _getConstraintsForAxis(BoxConstraints parentConstraints) {
    switch (widget.constrainedAxis) {
      case Axis.horizontal:
        // 水平自适应，垂直无限制
        return BoxConstraints(
            minWidth: 0,
            maxWidth: double.infinity,
            minHeight: 0,
            maxHeight: double.infinity);
      case Axis.vertical:
        // 垂直自适应，水平无限制
        return BoxConstraints(
            minWidth: 0,
            maxWidth: double.infinity,
            minHeight: 0,
            maxHeight: double.infinity);
    }
  }
}

/// 大小变化监听器
class SizeChangedNotifier extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size>? onSizeChanged;

  const SizeChangedNotifier(
      {super.key, required this.child, this.onSizeChanged});

  @override
  State<SizeChangedNotifier> createState() => _SizeChangedNotifierState();
}

class _SizeChangedNotifierState extends State<SizeChangedNotifier> {
  final GlobalKey _key = GlobalKey();
  Size? _oldSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSize());
  }

  @override
  void didUpdateWidget(SizeChangedNotifier oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSize());
  }

  void _checkSize() {
    if (!mounted) return;
    final context = _key.currentContext;
    if (context == null) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final newSize = renderBox.size;
      if (_oldSize != newSize) {
        _oldSize = newSize;
        widget.onSizeChanged?.call(newSize);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(key: _key, child: widget.child);
  }
}
