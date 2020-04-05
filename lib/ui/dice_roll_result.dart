import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rando/model.dart';

class DiceRollResult extends StatefulWidget {
  @override
  _DiceRollResultState createState() => _DiceRollResultState();
}

class _DiceRollResultState extends State<DiceRollResult>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  Item _result;
  @override
  void initState() {
    super.initState();
    _result = Provider.of<Collection>(context, listen: false).randomItem();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 250), (){
      _animationController.forward();
    });
    return Consumer<Collection>(
      builder: (context, collection, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              collection.name,
              style: Theme.of(context).textTheme.subtitle,
            ),
            iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).canvasColor,
          ),
          body: _body(context, collection),
          floatingActionButton: _fab(context),
        );
      },
    );
  }

  Widget _fab(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.center,
      child: FloatingActionButton.extended(
        icon: Image.asset(
          "assets/dice.png",
          width: 24,
          height: 24,
        ),
        label: Text("Next"),
        onPressed: () => _nextRandomItem(context),
      ),
    );
  }

  Widget _body(BuildContext context, Collection collection) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 88),
        child: Text(
          _result.name,
          style: Theme.of(context).textTheme.display3,
        ),
      ),
    );
  }

  void _nextRandomItem(BuildContext context) {
    setState(() {
      _result = Provider.of<Collection>(context, listen: false).randomItem();
    });
  }
}
