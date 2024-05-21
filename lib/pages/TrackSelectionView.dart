

import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:evitecompanion/config/app.dart';
import 'package:evitecompanion/config/appstyle.dart';
import 'package:evitecompanion/services/track.service.dart';
import 'package:evitecompanion/views/TrackCarouselCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TrackSelectionView extends StatefulWidget {
  const TrackSelectionView({super.key});

  @override
  State<TrackSelectionView> createState() => _TrackSelectionViewState();
}

class _TrackSelectionViewState extends State<TrackSelectionView> {
  final carouselController = CarouselController();
  Map<String, dynamic> eventData = {};
  List<dynamic> eventTracks = [];
  List<dynamic> tracksAgenda = [];
  bool tracksLoaded = false;
  Map<String, dynamic> trackSkeletonModel = {
    "name": "Lorem ipsum dolor sit amet",
    "description": "Lorem ipsum dolor sit amet",
    "venue": "Lorem ipsum dolor sit amet",
    "onlineLink": "Lorem ipsum dolor sit amet",
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<List<dynamic>> fetchData() async {
    var eventData = json.decode(localStorage.getItem('selectedEvent') as String);
    return TrackService.getTracksByEventId(eventData["id"])
      .then((result) {
        var parsedResult = json.decode(result.body);
        setState(() {
          tracksLoaded = true;
          eventTracks = parsedResult;
          if (eventTracks.isNotEmpty) {
            tracksAgenda = eventTracks[0]["agendaTopics"];
          }
        });
        return Future.value(parsedResult);
      });
  }

  void handleChangedIndex(int index, CarouselPageChangedReason reason){
    setState(() {
      tracksAgenda = eventTracks[index]["agendaTopics"];
    });
  }

  @override
  Widget build(BuildContext context) {
    eventData = json.decode(ModalRoute.of(context)!.settings.arguments as String);
    AppBar appBar = AppBar(
      backgroundColor: AppStyle.primary,
      title: const Text(App.title, style: TextStyle(
        color: Colors.white,
      )),
      centerTitle: true,
    );
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 15,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  side: const BorderSide(
                    width: 2,
                    color: Color.fromARGB(255, 73, 211, 135)
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  label: Text('${eventData["eventName"]}', style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w100,
                    color: Color.fromARGB(255, 73, 211, 135)
                  )),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 4,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(' Event Tracks', style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Skeletonizer(
                enabled: !tracksLoaded,
                child: CarouselSlider(
                  carouselController: carouselController,
                  options: CarouselOptions(
                    autoPlay: false,
         
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.scale,
                    onPageChanged: handleChangedIndex,
                    aspectRatio: 16/9,
                    enableInfiniteScroll: true,
                    initialPage: 0,
                    viewportFraction: 0.8,
                  ),
                  items: tracksLoaded 
                  ? (eventTracks.map((track) => TrackCarouselCard(track)).toList()) 
                  : ([1,2,3,4,5].map((track) => TrackCarouselCard(trackSkeletonModel)).toList())
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 15,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  side: const BorderSide(
                    width: 2,
                    color: Color.fromARGB(255, 73, 211, 135)
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  label: const Text('Agenda Topics', style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w100,
                    color: Color.fromARGB(255, 73, 211, 135)
                  )),
                ),
              ),
            ),      
            (tracksAgenda.isEmpty || !tracksLoaded)
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
                    const Text('No Data Found', style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    )),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        fetchData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyle.primary,
                      ),
                      child: const Text('Reload' , style: TextStyle(
                        color: Colors.white,
                      )),
                    )
                  ],
                ),
              ),
            )
            :       
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.transparent,
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Colors.grey),
                  itemCount: tracksAgenda.length,
                  itemBuilder: (context, index) {
                    var agenda = tracksAgenda[index];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        // A pane can dismiss the Slidable.
                        
                        children: [
                          SlidableAction(
                            onPressed: (ctx) {
                              localStorage.setItem('selectedAgenda', json.encode(agenda));
                              Navigator.pushNamed(context, '/attendance', arguments: json.encode(agenda));
                            },
                            backgroundColor: Colors.white,
                            foregroundColor: const Color.fromARGB(255, 70, 49, 49),
                            icon: Icons.no_accounts_outlined,
                            label: 'Attend...',
                          ),
                          SlidableAction(
                            onPressed: (ctx) {
                              localStorage.setItem('selectedAgenda', json.encode(agenda));
                              
                            },
                            backgroundColor: Colors.white,
                            foregroundColor: const Color.fromARGB(255, 70, 49, 49),
                            icon: CupertinoIcons.ticket,
                            label: 'Release',
                          ),
                        ],
                      ),
                      child: ListTile(
                        tileColor: const Color.fromARGB(255, 243, 243, 245),
                        title: Text((agenda["name"] as String).toUpperCase(), style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                        subtitle: Text(agenda["description"] as String),
                      ),
                    );
                  }
                ),
              ),
            )
          ]
        ),
      ),
    );
  }
}
