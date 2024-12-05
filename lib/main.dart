import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _hasPermissions = false;
  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermissions = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(builder: (context) {
          if (_hasPermissions) {
            return _buildCompass();
          } else {
            return _buildPermissionSheet();
          }
        }),
      ),
    );
  }

//compass
  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('error reading Heading:${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;
        if (direction == null) {
          return const Text('Device has no supporting senosrs');
        }

        return Center(
          child: Container(
            padding: EdgeInsets.all(25),
            child: Transform.rotate(
              angle: direction * (math.pi / 180) * -1,
              child: Image.asset(
                'assets/compass.png',
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

//permissionsheet
  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
        child: const Text('Request Permission'),
      ),
    );
  }
}
