import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'main.dart';

class NoNetworkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 8,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Icon(
                      Icons.error_outline,
                      size: 50.0,
                      color: Theme.of(context).errorColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Il semble que vous soyez hors connexion !',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: ButtonTheme(
                  minWidth: 300.0,
                  height: 50.0,
                  child: RaisedButton(
                    textColor: Colors.white,
                    elevation: 0.0,
                    child: const Text('Réessayer'),
                    onPressed: () async {
                      var connectivityResult =
                          await (Connectivity().checkConnectivity());
                      if (connectivityResult == ConnectivityResult.wifi ||
                          connectivityResult == ConnectivityResult.mobile) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Home(user: null),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}