import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import 'theme_provider.dart';
import 'auth.dart';
import 'settings.dart';
import 'no_network.dart';

import 'dart:async';

/// [main] function where we:
/// * Define the [statusBarColor] to transparent.
/// * Get the [isDarkTheme] boolean from the [SharedPreferences].
/// * Run the app via the [EppeTasksApp] widget.
/// In the the [runApp] method the [EppeTasksApp] widget is wrapped in the [ChangeNotifierProvider] to change the theme dynamically.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  final prefs = await SharedPreferences.getInstance();
  final isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkTheme: isDarkTheme),
      child: EppeTasksApp(),
    ),
  );
}

/// This is the root of the app.
class EppeTasksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Tasks',
      home: SplashScreen(),
      theme: themeProvider.getTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// The application starts by displaying this widget.
/// This is a [SplashScreen] that opens the [Home] page after 2 seconds.
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPreferences _prefs;

  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
      _checkConnectityAndSignIn,
    );
  }

  void _checkConnectityAndSignIn() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      _prefs = await SharedPreferences.getInstance();
      final accessToken = _prefs.getString('accessToken') ?? null;
      final idToken = _prefs.getString('idToken') ?? null;
      FirebaseUser user;
      if (accessToken != null && idToken != null) {
        user = await auth.handleSignIn(accessToken, idToken);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Home(user: user ?? null),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NoNetworkPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Hero(
            tag: 'icon',
            child: Icon(
              Icons.done_all,
              size: 100.0,
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// [Home] page of the app.
class Home extends StatefulWidget {
  final FirebaseUser user;

  Home({Key key, @required this.user}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _connected = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      _connected = false;
    } else {
      _connected = true;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        leading: Opacity(
          opacity: .5,
          child: Hero(
            tag: 'icon',
            child: Icon(Icons.done_all),
          ),
        ),
        title: Text(
          _connected ? 'Vos tâches' : 'Bienvenue !',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          SettingsButton(user: widget.user),
          _connected
              ? IconButton(
                  icon: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100.0),
                    ),
                    child: Image.network(widget.user.photoUrl),
                  ),
                  tooltip: 'Infos du compte',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      title: const Text('Votre compte'),
                      content: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(100.0),
                          ),
                          child: Image.network(widget.user.photoUrl),
                        ),
                        title: Text(
                          widget.user.displayName,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        subtitle: Text(
                          widget.user.email,
                          style: TextStyle(fontSize: 10.0),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: const Text('Fermer'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      body: _connected
          ? StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection('users')
                  .document(widget.user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                List tasks = snapshot.data['tasks'];
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                if (tasks.isEmpty)
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.done_outline,
                          size: 50.0,
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "Vous n'avez aucune tâche à effectuer, c'est du bon travail !",
                            style: TextStyle(fontSize: 24.0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                return ListView.builder(
                  itemCount: snapshot.data['tasks'].length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> task = snapshot.data['tasks'][index];
                    return Dismissible(
                      key: Key(task['name']),
                      onDismissed: (direction) {
                        final docRef = Firestore.instance
                            .collection('users')
                            .document(widget.user.uid);

                        docRef.updateData({
                          'tasks': FieldValue.arrayRemove([task]),
                        });

                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Tâche '${task['name']}' supprimée !",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).accentColor,
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          task['name'],
                          style: TextStyle(fontSize: 24.0),
                        ),
                        leading: Checkbox(
                          value: task['isDone'],
                          activeColor: Theme.of(context).accentColor,
                          onChanged: (val) async {
                            setState(() =>
                                tasks[index].update('isDone', (value) => val));
                            final document = await Firestore.instance
                                .collection('users')
                                .document(widget.user.uid)
                                .get();

                            document.reference.updateData({
                              'tasks': tasks,
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
                    child: Text(
                      'Pour accéder à vos tâches, vous devez vous connecter à votre compte Google !',
                      style: TextStyle(fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  RaisedButton.icon(
                    icon: Icon(FontAwesomeIcons.google),
                    label: Text('Se connecter avec Google'),
                    elevation: 0.0,
                    color: Color(0xFF4885ed),
                    textColor: Colors.white,
                    onPressed: () {
                      auth.handleSignIn().then((FirebaseUser user) async {
                        final docRef = Firestore.instance
                            .collection('users')
                            .document(user.uid);
                        final doc = await docRef.get();

                        if (!doc.exists) {
                          docRef.setData({
                            'tasks': [],
                          });
                        }

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Home(user: user),
                          ),
                        );
                      }).catchError((e) => print(e));
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: _connected
          ? FloatingActionButton(
              child: Icon(Icons.add),
              tooltip: 'Créer une tâche',
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Nouvelle tâche'),
                        content: Theme(
                          data: ThemeData(
                              primaryColor: Theme.of(context).accentColor,
                              fontFamily: 'Google Sans'),
                          child: TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Nom',
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Annuler'),
                            textColor: Theme.of(context).accentColor,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          RaisedButton(
                            child: Text('Ajouter'),
                            color: Theme.of(context).accentColor,
                            elevation: 0.0,
                            onPressed: () {
                              final docRef = Firestore.instance
                                  .collection('users')
                                  .document(widget.user.uid);
                              Map<String, dynamic> task = {
                                'name': controller.text,
                                'isDone': false,
                              };

                              docRef.updateData({
                                'tasks': FieldValue.arrayUnion([task]),
                              });

                              setState(() {
                                controller.clear();
                              });

                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
            )
          : null,
    );
  }
}