

import 'dart:convert';
import 'dart:developer';

import 'package:evitecompanion/config/appstyle.dart';
import 'package:evitecompanion/services/attendance.service.dart';
import 'package:evitecompanion/utils/datetoword.dart';
import 'package:evitecompanion/views/QrScanner.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final searchController = TextEditingController();
  final attendanceModeController = TextEditingController();
  Map<String, dynamic> agendaData = {};
  List<dynamic> data = [];
  int selectedAttendanceMode = 1;
  bool loaded = false;

  bool disposed = false;
  void mySetState(Function() fn) {
    if (!disposed) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<List<dynamic>> fetchAttendance() async {
    var selectedAgenda = json.decode(localStorage.getItem('selectedAgenda') as String);
    return AttendanceService.fetchAttendance(selectedAgenda['id'])
      .then((result) {
        mySetState(() {
          data = (json.decode(result.body) as List<dynamic>).reversed.toList();
          loaded = true;
        });
        return Future.value(data);
      })
      .catchError((err) {
        mySetState(() {
          loaded = true;
        });
        _showSnackbar('Failed to load attendance data.');
        return Future.value([]);
      });
  }

  List<dynamic> get computedData => data.where((user) {
    var text = user["participant"]["eventParticipant"]["applicationUser"]["fullName"];
    if (text.isEmpty) {
      text = user["participant"]["eventParticipant"]["applicationUser"]["userName"];
    }

    return 
      text.toString().toLowerCase().startsWith(searchController.text.toLowerCase()) &&
      user["type"] == selectedAttendanceMode;
  }).toList();

  Future<void> onAttendance(Map<String, dynamic> qrdata) async {
    var selectedAgenda = json.decode(localStorage.getItem('selectedAgenda') as String);
    return AttendanceService.addAttendance(selectedAgenda['id'], qrdata['eventParticipantId'], selectedAttendanceMode)
      .then((result) {
        if (result.statusCode != 200) return null;

        var parsedAttendance = json.decode(result.body);

        if (parsedAttendance['error'] == true) { // Maybe null?
          _showSnackbar(parsedAttendance['errorMessage']);
          return Future.value(null);
        }

        mySetState(() {
          data.insert(0, parsedAttendance);
        });
        _showSnackbar("Attendance submitted successfully.");
      })
      .catchError((err) {
        _showSnackbar("Failed to create attendance.");
      });
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
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
      title:Text(agendaData["name"] as String, style: const TextStyle(
        color: Colors.white,
      )),
      centerTitle: true,
    );
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchAttendance,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => mySetState(() {}),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Search',
                        hintText: 'Search',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownMenu(
                    controller: attendanceModeController,
                    initialSelection: 1,
                    enableSearch: false,
                    requestFocusOnTap: false,
                    enableFilter: false,
                    label: const Text('Mode'),
                    width: MediaQuery.of(context).size.width - 32,
                    onSelected: (attendanceMode) {
                      mySetState(() {
                        selectedAttendanceMode = attendanceMode;
                      });
                    },
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        return const Color.fromARGB(255, 226, 226, 233); //your desired selected background color
                      }),
                      
                      elevation: WidgetStateProperty.resolveWith((states) {
                        return 8; //desired elevation
                      }),
                    ),
                    dropdownMenuEntries: ([
                      {
                        "title": "In",
                        "value": 1
                      },
                      {
                        "title": "Out",
                        "value": 0
                      }
                    ] as List<dynamic>).map((attendanceMode) {
                        return DropdownMenuEntry(
                          value: attendanceMode['value'],
                          label: attendanceMode['title'],
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    child:  (computedData.isEmpty && loaded) ?
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
                                    mySetState(() {
                                      searchController.clear();
                                    });
                                    return;
                                  }
                                  else {
                                    // 
                                    fetchAttendance();
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Skeletonizer(
                        enabled: !loaded,
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Colors.grey),
                          itemCount: loaded ? computedData.length : 4,
                          itemBuilder: (BuildContext context, int index) {
                            var text = "Dummy Data";
                            if (loaded) {
                              text = computedData[index]["participant"]["eventParticipant"]["applicationUser"]["fullName"];
                              if (text.isEmpty) {
                                text = computedData[index]["participant"]["eventParticipant"]["applicationUser"]["userName"];
                              }
                            }
                            return ListTile(
                                tileColor: const Color.fromARGB(255, 226, 226, 233),
                                  title: Text(loaded ? text : 'Dummy Data'),
                                  subtitle: Text(loaded ? dateToWord(DateTime.parse(computedData[index]["log"])) : 'Dummy Data', style: const TextStyle(
                                    fontSize: 10
                                  )),
                                  trailing: const Icon(Icons.check),
                              );
                          },
                        ),
                      ),
                    )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const QRScannerView()))
          .then((content) {
            if (content == null) return;

            onAttendance(json.decode(content as String));
          });
        },
        tooltip: 'Scan QR Code',
        child: const Icon(Icons.qr_code_scanner),
      )
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    attendanceModeController.dispose();
    disposed = true;
    super.dispose();
  }
}