import 'package:flutter/material.dart';
import 'package:rando/common/theme.dart';

Future<String> showInputDialog(BuildContext context, String title,
    String valueTitle, String initialValue) async {
  String text;
  TextEditingController controller = TextEditingController(
    text: initialValue != null ? initialValue : "",
  );

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
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: valueTitle,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ThemeColors.primaryColor.withAlpha(200), width: 2),
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
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

enum DismissibleBackgroundIconPlacement { Left, Right }

Widget dismissibleBackground(
    BuildContext context, DismissibleBackgroundIconPlacement placement) {
  switch (placement) {
    case DismissibleBackgroundIconPlacement.Left:
      return Container(
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
          ],
        ),
      );
    case DismissibleBackgroundIconPlacement.Right:
      return Container(
        color: Colors.red,
        child: Row(
          children: <Widget>[
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
  }
  return null;
}
