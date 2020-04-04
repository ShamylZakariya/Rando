import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rando/common/theme.dart';
import 'package:rando/ui/collection_screen.dart';
import 'package:rando/model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CollectionStore(),
      child: RandoApp(),
    ),
  );
}

class RandoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Rando",
      home: CollectionScreen(),
      theme: appTheme(context),
    );
  }
}
