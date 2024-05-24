import 'dart:convert';
import 'package:evitecompanion/config/app.dart';
import 'package:evitecompanion/config/appstyle.dart';
import 'package:evitecompanion/services/organizer.service.dart';
import 'package:evitecompanion/views/OrganizerCard.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EventSelectionView extends StatefulWidget {
  const EventSelectionView({super.key});

  @override
  State<EventSelectionView> createState() => _EventSelectionViewState();
}

class _EventSelectionViewState extends State<EventSelectionView> {
  final searchController = TextEditingController();
  List<dynamic> myOrganizers = [];
  bool loaded = false;
  Map<String, dynamic> organizerSkeletonModel = {
    "organizerName": "Lorem ipsum dolor sit amet",
    "organizerEmail": "Lorem ipsum dolor sit amet",
    "organizerPhone": "Lorem ipsum dolor sit amet",
    "country": { "name": "Lorem ipsum" },
  };

  @override
  void initState() {
    super.initState();
    fetchData()
      .then((items) {
         if (activeAndEnabled.length == 1) {
          var stringOrganizer = json.encode(activeAndEnabled[0]);
            localStorage.setItem('selectedOrganizer', stringOrganizer);
            _showRedirectDialog();
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/eventList', arguments: stringOrganizer);
              return null;
            });
          }
      });
  }

  Future<List<dynamic>> fetchData() async {
    return OrganizerService.myOrganizer()
      .then((result) {
        if (result.statusCode != 200) {
          return Future.value([]);
        }

        var parsedResult = jsonDecode(result.body);

        setState(() {
          loaded = true;
          myOrganizers = parsedResult;
        });
        return Future.value(myOrganizers);
      })
      .catchError((error) {
        _showSnackbar('Failed to load organizer data.');
        return Future.value([]);
      });
  }

  Future<void> _showRedirectDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset('assets/images/animationload.gif', alignment: Alignment.center, fit: BoxFit.contain),
                ),
                const Text('Redirecting...', 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 31, 31, 31),
                    fontWeight: FontWeight.bold,
                  )
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppStyle.snackBar,
      content: Text(message, style: const TextStyle(color: AppStyle.snackBarText))
    ));
  }

  List<dynamic> get activeAndEnabled => myOrganizers.where((item) {
    var map = item as Map<String, dynamic>;

    if (searchController.text.isNotEmpty && (map["enable"] && map["isApproved"])) {
      return (map["organizerName"] as String).toLowerCase().startsWith(searchController.text.toLowerCase());
    }

    return (map["enable"] && map["isApproved"]);
  }).toList(); 

  bool get isMultipleChoice => activeAndEnabled.length > 1;

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      backgroundColor: AppStyle.primary,
      title: const Text(App.title, style: TextStyle(
        color: Colors.white,
      )),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: () {
          localStorage.clear();
          Navigator.of(context).pushReplacementNamed('/splash');
        },
      )
    );
    return Scaffold(
      appBar: appBar,
    
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Center(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Search Previous Organizer',
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
                  child: (activeAndEnabled.isEmpty && loaded) ?
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
                            const Text('No Organizer Found', style: TextStyle(
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
                        separatorBuilder: (context, index) => const SizedBox(height: 20),
                        itemCount: loaded ? activeAndEnabled.length : 4,
                        itemBuilder: (context, index) => OrganizerCard(loaded ? (activeAndEnabled[index] as Map<String, dynamic>) : organizerSkeletonModel, onTap: (data) {
                          if (!loaded) return;
                          var stringOrganizer = json.encode(data);
                          localStorage.setItem('selectedOrganizer', stringOrganizer);
                          Navigator.of(context).pushNamed('/eventList', arguments: stringOrganizer);
                        }),
                      ),
                    )
                      
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

