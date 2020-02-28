import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings.dart';
import 'auth.dart';

class Home extends StatefulWidget {
  final FirebaseUser user;

  Home({this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool connected = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      connected = false;
    } else {
      connected = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(connected ? 'Your Tasks' : 'Welcome!'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: connected ? EdgeInsets.only(bottom: 0.0) : null,
          children: <Widget>[
            connected
                ? UserAccountsDrawerHeader(
                    accountName: Text(widget.user.displayName),
                    accountEmail: Text(widget.user.email),
                    currentAccountPicture: CircleAvatar(
                      child: Image.network(widget.user.photoUrl),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Eppe Tasks',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            connected ? Container() : Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Settings(connected: connected),
                ),
              ),
            ),
          ],
        ),
      ),
      body: connected
          ? StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(widget.user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return ListView.builder(
                  itemCount: snapshot.data['tasks'].length,
                  itemBuilder: (context, index) {
                    String task = snapshot.data['tasks'][index];
                    return Dismissible(
                      key: Key(task),
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
                              "Task '$task' removed!",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
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
                          task,
                          style: TextStyle(fontSize: 24.0),
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
                      'To access to your tasks, you must sign in with your Google Account!',
                      style: TextStyle(fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  RaisedButton.icon(
                    icon: Icon(Icons.person_add),
                    label: Text('Sign in with Google'),
                    elevation: 0.0,
                    color: Color(0xFF4885ed),
                    textColor: Colors.white,
                    onPressed: () {
                      handleSignIn().then((FirebaseUser user) async {
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
                      });
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: connected
          ? FloatingActionButton(
              child: Icon(Icons.add),
              tooltip: 'Create a task',
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('New Task'),
                        content: TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Title',
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancel'),
                            textColor: Theme.of(context).accentColor,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          RaisedButton(
                            child: Text('Add'),
                            color: Theme.of(context).accentColor,
                            elevation: 0.0,
                            onPressed: () {
                              final docRef = Firestore.instance
                                  .collection('users')
                                  .document(widget.user.uid);
                              String task = controller.text;

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