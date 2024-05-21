

import 'dart:convert';

import 'package:evitecompanion/config/appstyle.dart';
import 'package:evitecompanion/views/QrScanner.dart';
import 'package:flutter/material.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  Map<String, dynamic> agendaData = {};

  @override
  Widget build(BuildContext context) {
    agendaData = json.decode(ModalRoute.of(context)!.settings.arguments as String);
    AppBar appBar = AppBar(
      backgroundColor: AppStyle.primary,
      title:Text('Attendance ${agendaData["name"]}', style: const TextStyle(
        color: Colors.white,
      )),
      centerTitle: true,
    );
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Text('Yeah!!'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,  MaterialPageRoute(builder: (context) => const QRScannerView()));
        },
        child: const Icon(Icons.qr_code_scanner),
        tooltip: 'Scan QR Code',
      )
    );
  }
}