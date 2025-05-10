import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  MapScreen({super.key, required this.camPos});

  LatLng camPos;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var titleCtrl = TextEditingController();

  var descCtrl = TextEditingController();
  final globalKey = GlobalKey<FormState>();
  Future<QuerySnapshot> fetchData() async {
    return await FirebaseFirestore.instance.collection('places').get();
  }

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favorite Places",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          List<QueryDocumentSnapshot> latlngs = [];
          if (snapshot.data != null) {
            latlngs = snapshot.data!.docs;
          }

          latlngs.forEach((e) {
            markers.add(
              Marker(
                markerId: MarkerId("$e"),
                position: LatLng(e['lat'], e['lng']),
                infoWindow: InfoWindow(
                  title: e['title'],
                  snippet: e['description'],
                ),
              ),
            );
          });

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.camPos,
              zoom: 10,
            ),

            markers: markers,
            onTap: (pos) {
              titleCtrl.clear();
              descCtrl.clear();
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(
                        "Add Detail About The Place",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Form(
                        key: globalKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Title", style: TextStyle(fontSize: 18)),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "*Tilte can't be empty!";
                                }
                                return null;
                              },
                              controller: titleCtrl,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text("Description", style: TextStyle(fontSize: 18)),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "*Description can't be empty!";
                                }
                                return null;
                              },
                              maxLines: null,
                              controller: descCtrl,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!globalKey.currentState!.validate()) {
                                    return;
                                  }
                                  await FirebaseFirestore.instance
                                      .collection('places')
                                      .add({
                                        'title': titleCtrl.text,
                                        'description': descCtrl.text,
                                        'lat': pos.latitude,
                                        'lng': pos.longitude,
                                        'dateAdded': DateTime.now(),
                                      });
                                  Navigator.of(context).pop();
                                  setState(() {});
                                  widget.camPos = pos;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Place added!")),
                                  );
                                },
                                child: Text("Add"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
