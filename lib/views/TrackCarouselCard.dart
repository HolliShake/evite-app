


import 'dart:math';

import 'package:flutter/material.dart';

class TrackCarouselCard extends StatelessWidget {
  final Map<String, dynamic> data;
  TrackCarouselCard(this.data, {super.key});

  final List<String> _images = [
    "assets/images/loginbg.jpg",
    "assets/images/planning1.png",
    "assets/images/planning2.jpg",
    "assets/images/planning3.png",
    "assets/images/planning4.jpg"
  ];


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.width / 2.5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(_images[Random().nextInt(_images.length)]),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
          ),
        ),
        // square
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${data["name"]}", style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w100,
                color: Colors.white,
                overflow: TextOverflow.fade
              )),
              Text((data["description"] as String), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12, overflow: TextOverflow.fade)),
              const SizedBox(height:10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  spacing: 5,
                  children: [
                    Chip(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      side: const BorderSide(
                        width: 0,
                        color: Colors.transparent
                      ),
                      visualDensity: VisualDensity.compact,
                      label: Wrap(
                        direction: Axis.horizontal,
                        spacing: 2,
                        clipBehavior: Clip.hardEdge,
                        children: [
                          const Icon(Icons.location_pin, size: 18, color: Colors.redAccent),
                          Text(data["venue"] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w100, fontSize: 10, overflow:  TextOverflow.fade))
                        ],
                      ), 
                      labelPadding: EdgeInsets.zero,
                      backgroundColor: const Color.fromARGB(255, 221, 191, 84), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    Chip(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      side: const BorderSide(
                        width: 0,
                        color: Colors.transparent
                      ),
                      visualDensity: VisualDensity.compact,
                      label: Wrap(
                        direction: Axis.horizontal,
                        spacing: 2,
                        clipBehavior: Clip.hardEdge,
                        children: [
                          const Icon(Icons.phone_android, size: 16, color: Colors.white),
                          Text(data["onlineLink"] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10))
                        ],
                      ), 
                      labelPadding: EdgeInsets.zero,
                      backgroundColor: const Color.fromARGB(255, 92, 36, 223), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: BorderSide.none
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


