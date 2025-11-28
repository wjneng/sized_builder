# SizedBuilder

一个轻量级的 Flutter 组件，用于实时计算子组件的尺寸并通过回调返回结果，支持监听组件尺寸动态变化，适配不同布局场景的尺寸测量需求。

## 🌟 特性
- 实时计算指定组件的尺寸，通过 builder 回调返回最新尺寸
- 自动监听组件尺寸变化，动态更新回调结果
- 支持指定水平/垂直约束轴，适配不同布局场景
- 无侵入式设计，不影响原有组件的展示与交互
- 零第三方依赖，兼容 Flutter 3.0+ 全版本
- 提供独立的 `SizeChangedNotifier` 组件，支持单独监听尺寸变化

## 📋 使用
```dart
SizedBuilder(
    measuredChild: _buildCustomView(),
    builder: (context, customWidgetSize, customWidget) {
        return Container(
            decoration: BoxDecoration(color: Colors.green),
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        customWidget, 
                        Text('$customWidgetSize')
                    ],
                ),
            ),
        );
    },
),
```