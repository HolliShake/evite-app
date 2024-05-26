

import 'dart:convert';
import 'dart:developer';

import 'package:evitecompanion/config/appstyle.dart';
import 'package:evitecompanion/services/attendance.service.dart';
import 'package:evitecompanion/utils/datetoword.dart';
import 'package:evitecompanion/views/QrScanner.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:skeletonizer/skeletonizer.dart';


class EventAttendanceView extends StatefulWidget {
  const EventAttendanceView({super.key});

  @override
  State<EventAttendanceView> createState() => _EventAttendanceViewState();
}

class _EventAttendanceViewState extends State<EventAttendanceView> {
  final searchController = TextEditingController();
  final attendanceTypeController = TextEditingController();
  final attendanceModeController = TextEditingController();
  Map<String, dynamic> eventData = {};
  List<dynamic> data = [];
  List<dynamic> attendanceType = [];
  int selectedAttendanceType = 0;
  int selectedAttendanceMode = 1;
  bool typesLoaded = false;
  bool loaded = false;
  bool popable = false;
  
  bool disposed = false;
  void mySetState(Function() fn) {
    if (!disposed) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      fetchAttendanceType()
        .then((_) {
          fetchAttendance();
        });
    });
  }

  Future<List<dynamic>> fetchAttendanceType() async {
    var selectedEvent = json.decode(localStorage.getItem('selectedEvent') as String);
    return AttendanceService.fetchAttendanceType(selectedEvent['id'])
      .then((result) {
        mySetState(() {
          typesLoaded = true;
          attendanceType = json.decode(result.body);
          selectedAttendanceType = attendanceType.isNotEmpty ? attendanceType[0]['id'] : 0;
        });
        return Future.value(attendanceType);
      })
      .catchError((err) {
        mySetState(() {
          typesLoaded = true;
        });
        _showSnackbar('Failed to load attendance type.');
        return Future.value([]);
      });
  }

  Future<List<dynamic>> fetchAttendance() async {
    var selectedEvent = json.decode(localStorage.getItem('selectedEvent') as String);
    return AttendanceService.fetchAttendanceByEventAndType(selectedEvent['id'], selectedAttendanceType)
      .then((result) {
        mySetState(() {
          loaded = true;
          data = (json.decode(result.body) as List<dynamic>).reversed.toList();
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

  Future<void> fetchReload() async {
    var selectedEvent = json.decode(localStorage.getItem('selectedEvent') as String);
    var attendanceTypeResponse = await AttendanceService.fetchAttendanceType(selectedEvent['id']);
    if (attendanceTypeResponse.statusCode == 200) {
        typesLoaded = true;
        attendanceType = json.decode(attendanceTypeResponse.body);
        selectedAttendanceType = attendanceType.isNotEmpty ? attendanceType[0]['id'] : 0;
        // Fetch attendance
        var attendanceResponse = await AttendanceService.fetchAttendanceByEventAndType(selectedEvent['id'], selectedAttendanceType);
        if (attendanceResponse.statusCode == 200) {
          loaded = true;
          data = (json.decode(attendanceResponse.body) as List<dynamic>).reversed.toList();
          mySetState(() {});
        } else {
          _showSnackbar('Failed to load attendance data.');
        }
    } else {
      _showSnackbar('Failed to load attendance type.');
    }
  }

  List<dynamic> get computedData => data.where((user) => 
    user["name"].toString().toLowerCase().startsWith(searchController.text.toLowerCase()) &&
    user["type"] == selectedAttendanceMode &&
    user["eventAttendanceTypeId"] == selectedAttendanceType
  ).toList();

  Future<void> onAttendance(Map<String, dynamic> qrdata) async {
    AttendanceService.addEventAttendance(qrdata['eventParticipantId'], selectedAttendanceType, selectedAttendanceMode)
      .then((result) {
        if (result.statusCode != 200) return null;

        var parsedAttendance = json.decode(result.body);

        if (parsedAttendance['error'] == true) { // Maybe null?
          _showSnackbar(parsedAttendance['errorMessage']);
          return Future.value(null);
        }

        setState(() {
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

  Future<void> askToExit() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  popable = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    eventData = json.decode(ModalRoute.of(context)!.settings.arguments as String);
    AppBar appBar = AppBar(
      backgroundColor: AppStyle.primary,
      title:Text('${eventData["eventName"]}', style: const TextStyle(
        color: Colors.white,
      )),
      centerTitle: true,
    );
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchReload,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
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
                  DropdownMenu(
                    controller: attendanceTypeController,
                    initialSelection: attendanceType.isNotEmpty ? attendanceType[0]['id'] : 0,
                    enableSearch: false,
                    requestFocusOnTap: false,
                    enableFilter: false,
                    label: const Text('Attendance Type'),
                    width: MediaQuery.of(context).size.width - 32,
                    onSelected: (attendanceType) {
                      setState(() {
                        selectedAttendanceType = attendanceType;
                        fetchAttendance();
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
                    dropdownMenuEntries: attendanceType.map((attendanceType) {
                        return DropdownMenuEntry(
                          value: attendanceType['id'],
                          label: attendanceType['type'],
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 15),
                  DropdownMenu(
                    controller: attendanceModeController,
                    initialSelection: 1,
                    enableSearch: false,
                    requestFocusOnTap: false,
                    enableFilter: false,
                    label: const Text('Mode'),
                    width: MediaQuery.of(context).size.width - 32,
                    onSelected: (attendanceMode) {
                      setState(() {
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
                  const SizedBox(height: 10),
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
                                    setState(() {
                                      searchController.clear();
                                    });
                                    return;
                                  }
                                  else {
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
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Colors.grey),
                          itemCount: loaded ? computedData.length : 4,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                tileColor: const Color.fromARGB(255, 226, 226, 233),
                                title: Text(loaded ? computedData[index]["eventParticipant"].toString() : 'Dummy Data'),
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
          if (selectedAttendanceType == 0) {
            _showSnackbar('Please select attendance type.');
            return;
          }
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
    // TODO: implement dispose
    searchController.dispose();
    attendanceTypeController.dispose();
    attendanceModeController.dispose();
    disposed = true;
    super.dispose();
  }
}