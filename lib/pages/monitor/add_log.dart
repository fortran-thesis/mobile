import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Log Screen'),
      ),
    );
  }
}