import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/material.dart';

class OrganizerCard extends StatefulWidget {
  final Map<String, dynamic> data;
  Function(Map<String, dynamic> data) onTap;
  OrganizerCard(this.data, {required this.onTap, super.key});

  @override
  State<OrganizerCard> createState() => _OrganizerCardState();
}

class _OrganizerCardState extends State<OrganizerCard> {
  final List<String> _images = [
    "assets/images/loginbg.jpg",
    "assets/images/planning1.png",
    "assets/images/planning2.jpg",
    "assets/images/planning3.png",
    "assets/images/planning4.jpg"
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(widget.data),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.width / 2,
          ),
          decoration: BoxDecoration(
            color: Colors.amberAccent,
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
                Text("${widget.data["organizerName"]}", style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                  color: Colors.white,
                  overflow: TextOverflow.fade
                )),
                Text(widget.data["organizerEmail"] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12, overflow: TextOverflow.fade)),
                const SizedBox(height:10),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Wrap(
                    spacing: 10,
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    children: [
                      Chip(
                        side: const BorderSide(
                          width: 0,
                          color: Colors.transparent
                        ),
                        label: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            const Icon(Icons.location_pin, size: 18, color: Colors.redAccent),
                            const SizedBox(width: 5),
                            Text((widget.data["country"]) as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12, overflow:  TextOverflow.fade))
                          ],
                        ), 
                        labelPadding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                        backgroundColor: const Color.fromARGB(255, 221, 191, 84), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      Chip(
                        side: const BorderSide(
                          width: 0,
                          color: Colors.transparent
                        ),
                        label: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            const Icon(Icons.phone_android, size: 18, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(widget.data["organizerPhone"] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12))
                          ],
                        ), 
                        labelPadding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
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
      ),
    );
  }
}