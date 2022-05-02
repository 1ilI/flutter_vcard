# flutter_vcard

一个垂直滑动的卡片堆叠控件

![demo_gif](https://github.com/1ilI/flutter_vcard/blob/master/example/vcard.gif)

## Usage 

To use this plugin, add `flutter_vcard` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example

``` dart
// import package
import 'package:flutter_vcard/flutter_vcard.dart';
import 'package:flutter/material.dart';

    VCardView(
        size: Size(width, height),
        controller: controller,
        itemCount: colors.length,
        itemBuild: (context, index) {
          return Card(
            child: Container(color: colors[index]),
          );
        },
        endCallback: () {
          print('---->end');
        },
        indexChangeCallback: (index) {
          print('changed--->$index');
        },
        nextCallback: (index) {
          print('next--->$index');
        },
        previousCallback: (index) {
          print('previous--->$index');
        },
    );
```
