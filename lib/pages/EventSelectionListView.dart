import 'dart:convert';
import 'dart:developer';
import 'package:evitecompanion/config/appstyle.dart';
import 'package:evitecompanion/services/events.service.dart';
import 'package:evitecompanion/views/EventCard.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EventSelectionListView extends StatefulWidget {
  const EventSelectionListView({super.key});

  @override
  State<EventSelectionListView> createState() => _EventSelectionListViewState();
}

class _EventSelectionListViewState extends State<EventSelectionListView> {
  final searchController = TextEditingController();
  Map<String, dynamic> organizerData = {};
  List<dynamic> organizerEvents = [];
  bool loaded = false;
  Map<String, dynamic> eventSkeletonModel = {
    "eventName": "Lorem ipsum dolor sit amet",
    "description": "Lorem ipsum dolor sit amet",
    "eventVenue": "Lorem ipsum dolor sit amet",
    "onlineLink": "Lorem ipsum dolor sit amet",
    "eventBanner": ""
  };

  bool disposed = false;
  void mySetState(Function() fn) {
    if (!disposed) setState(fn);
  }

  @override
  initState() {
    super.initState();
    fetchData();
  }

  Future<List<dynamic>> fetchData() async {
    var organizerData = json.decode(localStorage.getItem('selectedOrganizer') as String);
    return EventService.getEventsByOrganizerId(organizerData["id"])
      .then((result) {
        if (result.statusCode != 200) {
          return Future.value([]);
        }
        mySetState(() {
          loaded = true;
          organizerEvents = json.decode(result.body);
        });
        return Future.value(organizerEvents);
      })
      .catchError((error) {
        mySetState(() {
          loaded = true;
        });
        _showSnackbar('Failed to load event data.');
        return Future.value([]);
      });
  }

  List<dynamic> get filteredEvents => organizerEvents.where((element) {
    if (searchController.text.isEmpty) return true;
    return (element["eventName"] as String).toLowerCase().contains(searchController.text.toLowerCase());
  }).toList();
  
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppStyle.snackBar,
      content: Text(message, style: const TextStyle(color: AppStyle.snackBarText))
    ));
  }

  @override
  Widget build(BuildContext context) {
    organizerData = json.decode(ModalRoute.of(context)?.settings.arguments as String);
    AppBar appBar = AppBar(
      backgroundColor: AppStyle.primary,
      title:Text(organizerData["organizerName"] as String, style: const TextStyle(
        color: Colors.white,
      )),
      centerTitle: true,
    );
    return Scaffold(
      appBar: appBar,
      
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchData,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Center(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) => mySetState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Search Events',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - (appBar.preferredSize.height + 50 + 20 + (20 + 20)), // Appbar + Search + spaceing + (Padding + Padding)
                    child: (filteredEvents.isEmpty && loaded)
                      ?
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
                              const Text('No Event Found', style: TextStyle(
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
                                    fetchData();
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
                      Skeletonizer(
                          enabled: !loaded,
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const SizedBox(height: 20),
                            itemCount:  loaded ? filteredEvents.length : 4,
                            itemBuilder: (context, index) => EventCard( loaded ? (filteredEvents[index] as Map<String, dynamic>) : eventSkeletonModel, onTap: (data) {
                              if (!loaded) return;
                              localStorage.setItem('selectedEvent', json.encode(data));
                              Navigator.of(context).pushNamed('/trackSelection', arguments: json.encode(data));
                            }),
                          ),
                        )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    disposed = true;
    super.dispose();
  }
}