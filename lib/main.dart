import 'package:flutter/material.dart';
// import '01/HellowWorld.dart';
// import '02/TextWidget.dart';
// import '02/Container.dart';
// import '02/Image.dart';
// import '02/ListView.dart';
// import '02/ListView.horizontal.dart';
import '02/ListView.builder.dart';

// 主入口函数
// void main() => runApp(MyApp());
void main() => runApp(MyApp(
  items: List<String>.generate(1000, (i) => 'Items $i')
));