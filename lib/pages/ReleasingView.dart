

import 'dart:convert';
import 'dart:developer';

import 'package:evitecompanion/config/appstyle.dart';
import 'package:evitecompanion/services/release.service.dart';
import 'package:evitecompanion/utils/datetoword.dart';
import 'package:evitecompanion/views/QrScanner.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReleasingView extends StatefulWidget {
  const ReleasingView({super.key});

  @override
  State<ReleasingView> createState() => _ReleasingViewState();
}

class _ReleasingViewState extends State<ReleasingView> {
  final searchController = TextEditingController();
  final releaseTypeController = TextEditingController();
  Map<String, dynamic> agendaData = {};
  List<dynamic> releaseTypes = [];
  List<dynamic> releases = [];
  int selectedReleaseType = 0;
  bool loaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchReleaseTypes()
      .then((data) {
        fetchRelease();
      });
  }

  Future<List<dynamic>> fetchReleaseTypes() async {
    var agendaData = json.decode(localStorage.getItem('selectedAgenda') as String);
    return ReleaseService.getReleaseTypesByAgendaTopicId(agendaData["id"])
      .then((result) {
        if (result.statusCode != 200) return Future.value([]);

        setState(() {
          releaseTypes = json.decode(result.body);
          selectedReleaseType = releaseTypes.isNotEmpty ? releaseTypes[0]['id'] : 0;
          log(releaseTypes.toString());
        });

        return Future.value(releaseTypes);
      })
      .catchError((error) {
        return Future.value([]);
      });

  }

  Future<List<dynamic>> fetchRelease() async {
    setState(() {
      releases = [];
      loaded = false;
    });
    return ReleaseService.fetchRelease(selectedReleaseType)
      .then((result) {
        if (result.statusCode != 200) return Future.value([]);

        setState(() {
          releases = (json.decode(result.body) as List<dynamic>).reversed.toList();
          loaded = true;
        });

        return Future.value(releases);
      })
      .catchError((error) {
        setState(() {
          loaded = true;
        });
        _showSnackbar('Failed to load release data.');
        return Future.value([]);
      });
  }

  void onRelease(Map<String, dynamic> qrdata) {
    log(selectedReleaseType.toString());
    log(qrdata["eventParticipantId"].toString());
    ReleaseService.addRelease(selectedReleaseType, qrdata["eventParticipantId"])
      .then((result) {
        if (result.statusCode < 200 || result.statusCode >= 300) {
          log(result.body);
          _showSnackbar('Failed to release participant(${result.statusCode}).');
          return null;
        }

        log('created');
        log(result.body);

        var parsedRelease = json.decode(result.body);

        if (parsedRelease is! List) {
          if (parsedRelease['error'] == true) { // Maybe null?
            _showSnackbar(parsedRelease['errorMessage']);
            return Future.value(null);
          }
        }

        setState(() {
          releases.insert(0, parsedRelease[0]);
        });
        _showSnackbar('Participant released.');
      })
      .catchError((error) {
        log(error.toString());
        _showSnackbar('Failed to load release data.');
      });
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppStyle.snackBar,
      content: Text(message, style: const TextStyle(color: AppStyle.snackBarText))
    ));
  }

  List<dynamic> get computedData => releases.where((release) => 
  
      release["releaseType"].toString().toLowerCase().startsWith(searchController.text.toLowerCase()) &&
      release["releaseTypeId"] == selectedReleaseType

  ).toList();

  @override
  Widget build(BuildContext context) {
    agendaData = json.decode(ModalRoute.of(context)!.settings.arguments as String);
    AppBar appBar = AppBar(
      backgroundColor: AppStyle.primary,
      title:Text('${agendaData["name"]}', style: const TextStyle(
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
                  controller: releaseTypeController,
                  initialSelection: releaseTypes.isNotEmpty ? releaseTypes[0]['id'] : 0,
                  enableSearch: false,
                  requestFocusOnTap: false,
                  enableFilter: false,
                  label: const Text('Release Type'),
                  width: MediaQuery.of(context).size.width - 32,
                  onSelected: (releaseType) {
                    setState(() {
                      selectedReleaseType = releaseType;
                      fetchRelease();
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
                  dropdownMenuEntries: releaseTypes.map((releaseType) {
                      return DropdownMenuEntry(
                        value: releaseType['id'],
                        label: releaseType['type'],
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
                                  fetchRelease();
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
      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const QRScannerView()))
          .then((content) {
            if (content == null) return;

            log(content.toString());
            onRelease(json.decode(content as String));
          });
        },
        tooltip: 'Scan QR Code',
        child: const Icon(Icons.qr_code_scanner),
      )
    );
  }
}