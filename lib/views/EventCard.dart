import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';


class EventCard extends StatefulWidget {
  final Map<String, dynamic> data;
  Function(Map<String, dynamic>) onTap;
  EventCard(this.data, {required this.onTap, super.key});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final List<String> _images = [
    "assets/images/loginbg.jpg",
    "assets/images/planning1.png",
    "assets/images/planning2.jpg",
    "assets/images/planning3.png",
    "assets/images/planning4.jpg"
  ];
  dynamic image;


  dynamic bannerOrRandom() {
    if ((widget.data["eventBanner"] as String).isNotEmpty) {
      try {
        return NetworkImage("https://evitepro-api.ustp.edu.ph/Files/${widget.data["eventBanner"]}");
      } catch (e) {
        // 
      }
    }
    return AssetImage(_images[Random().nextInt(_images.length)]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image = bannerOrRandom();
    developer.log(widget.data.toString());
  }
  
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
              image: image,
              onError: (_, __) {
                setState(() {
                  image = AssetImage(_images[Random().nextInt(_images.length)]);
                });
              },
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
                Text("${widget.data["eventName"]}", style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                  color: Colors.white,
                  overflow: TextOverflow.fade
                )),
                // Text(widget.data["description"] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12, overflow: TextOverflow.fade)),
                Html(
                  data: '<pre>${widget.data["description"] as String}</pre>',
                  style: {
                    "*": Style(
                      color: Colors.white,
                    ),
                    "h1": Style(
                      color: Colors.white,
                    ),
                    "h2": Style(
                      color: Colors.white,
                    ),
                    "h3": Style(
                      color: Colors.white,
                    ),
                    "h4": Style(
                      color: Colors.white,
                    ),
                    "h5": Style(
                      color: Colors.white,
                    ),
                    "h6": Style(
                      color: Colors.white,
                    ),
                    "small": Style(
                      color: Colors.white,
                    ),
                    "q": Style(
                      color: Colors.white,
                    ),
                    "b": Style(
                      color: Colors.white,
                    ),
                    "i": Style(
                      color: Colors.white,
                    ),
                    "span": Style(
                      color: Colors.white,
                    ),
                    "div": Style(
                      color: Colors.white,
                    ),
                    "p": Style(
                      color: Colors.white,
                    ),
                    "pre": Style(
                      color: Colors.white,
                    ),
                  },
                ),
                const SizedBox(height:10),
            
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    children: [
                      Chip(
                        elevation: 900,
                        side: const BorderSide(
                          width: 0,
                          color: Colors.transparent
                        ),
                        label: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            const Icon(Icons.location_pin, size: 18, color: Colors.redAccent),
                            const SizedBox(width: 5),
                            Text(widget.data["eventVenue"] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12, overflow:  TextOverflow.fade))
                          ],
                        ), 
                        labelPadding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                        backgroundColor: const Color.fromARGB(255, 221, 191, 84), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      Chip(
                        elevation: 900,
                        side: const BorderSide(
                          width: 0,
                          color: Colors.transparent
                        ),
                        label: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            const Icon(Icons.link, size: 18, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(widget.data["onlineLink"] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12))
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