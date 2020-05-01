import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:rando/common/theme.dart';
import 'package:rando/ui/collection_screen.dart';
import 'package:rando/model.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: MaterialApp(
        title: "Rando",
        home: CollectionScreen(),
        theme: appTheme(context),
      ),
    );
  }
}
