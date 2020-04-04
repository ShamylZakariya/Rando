import 'package:flutter/material.dart';
import 'package:rando/model.dart';

Future<String> showInputDialog(BuildContext context, String title,
    String valueTitle, String initialValue) async {
  String text;
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context).textTheme.display1,
          ),
          content: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: TextEditingController()
                    ..text = initialValue != null ? initialValue : "",
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: valueTitle,
                  ),
                  onChanged: (value) {
                    text = value;
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(text);
              },
            ),
          ],
        );
      });
}

Widget dismissibleBackground(BuildContext context) => Container(
      color: Colors.red,
      child: Row(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Icon(
              Icons.delete,
              color: Colors.white.withAlpha(194),
            ),
          ),
          Spacer(),
          AspectRatio(
            aspectRatio: 1,
            child: Icon(
              Icons.delete,
              color: Colors.white.withAlpha(194),
            ),
          ),
        ],
      ),
    );

void showDiceRollResultDialog(
    BuildContext context, Collection collection, Item item) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "You got",
            style: Theme.of(context).textTheme.display1,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.name,
                style: Theme.of(context).textTheme.display3,
                textAlign: TextAlign.start,
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}