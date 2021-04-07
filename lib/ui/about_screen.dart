import 'package:flutter/material.dart';
import 'package:rando/common/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final String _freePickUrl = "https://www.flaticon.com/authors/freepik";
  final String _sourceUrl = "https://github.com/ShamylZakariya/Rando";

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(
          title: Text("about", style: Theme.of(context).textTheme.headline6),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: _body(context),
    ));
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 64),
      child: Center(
        child: Column(
          children: <Widget>[
            Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                "rando",
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            Text(
              "A simple app for picking a thing at random, because sometimes that's a thing you have to do.",
              textAlign: TextAlign.center,
            ),
            Spacer(
              flex: 1,
            ),
            _linkButton(context, "github.com/ShamylZakariya/rando", _sourceUrl),
            _linkButton(context, "icons from freepick.com", _freePickUrl),
          ],
        ),
      ),
    );
  }

  Widget _linkButton(BuildContext context, String title, String url) =>
      SizedBox(
        width: double.infinity,
        child: TextButton(
          child: Text(title),
          style: raisedButtonStyle,
          onPressed: () => _navigateTo(url),
        ),
      );

  void _navigateTo(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true, forceSafariVC: true);
    } else {
      print("Unable to launch url $url");
    }
  }
}
