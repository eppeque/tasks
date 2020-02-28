import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'auth.dart';
import 'home.dart';

class Settings extends StatefulWidget {
  final bool connected;

  Settings({this.connected});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: Text('Dark Theme'),
            value: themeProvider.isDarkTheme,
            onChanged: (val) {
              setState(() {
                themeProvider.setTheme = val;
              });
            },
          ),
          widget.connected
              ? ListTile(
                  leading: Icon(Icons.highlight_off),
                  title: Text('Log out'),
                  onTap: () {
                    signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Home(),
                      ),
                    );
                  },
                )
              : Container(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version $_version'),
            subtitle: Text('Developed by Eppe, LLC. with Flutter and Firebase.'),
          ),
        ],
      ),
    );
  }
}