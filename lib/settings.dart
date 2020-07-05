import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_provider.dart';
import 'auth.dart';
import 'main.dart';

/// [SettingsButton] for the [AppBar] actions.
/// It's basically an [IconButton] that [showModalBottomSheet].
class SettingsButton extends StatefulWidget {
  final FirebaseUser user;

  const SettingsButton({Key key, @required this.user}) : super(key: key);

  @override
  _SettingsButtonState createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _getPrefs();
  }

  Future<Null> _getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return IconButton(
      icon: Icon(Icons.settings),
      tooltip: 'Accéder aux paramètres',
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              'Paramètres',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0.0,
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              ListTile(
                title: const Text('Thème sombre'),
                leading: Icon(
                  Icons.brightness_medium,
                  color: Theme.of(context).accentColor,
                ),
                trailing: Switch(
                  value: themeProvider.isDarkTheme,
                  onChanged: (val) {
                    themeProvider.setTheme = val;
                    _prefs.setBool('isDarkTheme', val);
                  },
                  activeColor: Theme.of(context).accentColor,
                ),
              ),
              widget.user == null
                  ? Container()
                  : ListTile(
                      leading: Icon(
                        Icons.highlight_off,
                        color: Theme.of(context).errorColor,
                      ),
                      title: Text('Se déconnecter'),
                      onTap: () {
                        signOut();
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Home(
                              user: null,
                            ),
                          ),
                        );
                      },
                    ),
              AboutListTile(
                child: Text('À propos de cette application'),
                icon: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).accentColor,
                ),
                applicationIcon: Icon(
                  Icons.done_all,
                  color: Theme.of(context).accentColor,
                ),
                applicationName: 'Eppe Tasks',
                applicationVersion: '2.0.0',
                applicationLegalese:
                    'Cette application est développée par Quentin Eppe. Tous droits réservés.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}