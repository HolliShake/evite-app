

import 'dart:convert';

import 'package:evitecompanion/config/appstyle.dart';
import 'package:evitecompanion/services/attendance.service.dart';
import 'package:evitecompanion/views/QrScanner.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final searchController = TextEditingController();
  Map<String, dynamic> agendaData = {};
  List<Map<String, dynamic>> data = [
    {
      "name": "Philipp Andrew Redondo",
    },
    {
      "name": "Xercis Silao",
    }
  ];

  List<Map<String, dynamic>> get computedData => data.where((user) => user["name"].toString().toLowerCase().startsWith(searchController.text.toLowerCase())).toList();

  Future<void> onAttendance(String qrdata) async {
    var selectedAgenda = json.decode(localStorage.getItem('selectedAgenda') as String);
    AttendanceService.submitAttendance(1, int.parse(qrdata), selectedAgenda['id'])
      .then((result) {
        if (result.statusCode != 200) return;
        setState(() {
          data.add(json.decode(result.body));
        });
        _showSnackbar("Attendance submitted successfully.");
      })
      .catchError((err) {
        _showSnackbar("Failed to create attendance.");
      });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppStyle.snackBar,
      content: Text(message, style: const TextStyle(color: AppStyle.snackBarText))
    ));
  }

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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      hintText: 'Search',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child:  (computedData.isEmpty) ?
                  SingleChildScrollView(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image(
                              image: const AssetImage('assets/images/nodata.jpg'),
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.width * 0.7,
                            ),
                            const Text('No Data Found', style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                            )),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (searchController.text.isNotEmpty) {
                                  setState(() {
                                    searchController.clear();
                                  });
                                  return;
                                }
                                else {
                                  // 
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyle.primary,
                              ),
                              child: Text(searchController.text.isEmpty ? 'Reload' : 'Try again', style: const TextStyle(
                                color: Colors.white,
                              )),
                            )
                          ],
                        ),
                      ),
                    )
                  :
                  Card(
                    color: Colors.transparent,
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Colors.grey),
                      itemCount: computedData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            tileColor: Color.fromARGB(255, 226, 234, 240),
                            title: Text(computedData[index]["name"].toString()),
                            trailing: const Icon(Icons.check),
                          );
                      },
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var result = Navigator.push(context,  MaterialPageRoute(builder: (context) => const QRScannerView()));
          onAttendance(result as String);
        },
        child: const Icon(Icons.qr_code_scanner),
        tooltip: 'Scan QR Code',
      )
    );
  }
}