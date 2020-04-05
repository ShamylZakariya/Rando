import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final String _freePickUrl = "https://www.flaticon.com/authors/freepik";
  final String _sourceUrl = "https://github.com/ShamylZakariya/Rando";

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: Text("about", style: Theme.of(context).textTheme.title),
        elevation: 0,
      ),
      body: _body(context),
    ));
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(64.0),
      child: Center(
        child: Column(
          children: <Widget>[
            Spacer(flex: 1,),
            Text(
              "rando",
              style: Theme.of(context).textTheme.display2,
            ),
            Text(
              "A simple app for picking a thing at random, because sometimes that's a useful thing to do.",
              textAlign: TextAlign.center,
            ),
            Spacer(flex: 1,),
            RaisedButton(
              child: Text("source"),
              onPressed: ()=>_navigateTo(_sourceUrl),
              color: Colors.cyan,
              textColor: Colors.white,
            ),
            RaisedButton(
              child: Text("icons from freepick.com"),
              onPressed: ()=>_navigateTo(_freePickUrl),
              color: Colors.cyan,
              textColor: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  void _navigateTo(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Unable to launch url $url");
    }
  }
}
