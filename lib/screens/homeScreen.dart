import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:take_home_quiz/screens/mapScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var titleCtrl = TextEditingController();

  var descCtrl = TextEditingController();
  var dateCtrl = TextEditingController();
  DateTime? date;

  Stream<QuerySnapshot> fetchData() {
    return FirebaseFirestore.instance
        .collection('places')
        .orderBy('title')
        .snapshots();
  }

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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) =>
                          MapScreen(camPos: LatLng(15.9724207, 120.5215633)),
                ),
              );
            },
            icon: Icon(Icons.map),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No found data!"));
          }
          List<QueryDocumentSnapshot> faveplaces = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: faveplaces.length,
                    itemBuilder: (BuildContext context, int index) {
                      var title = faveplaces[index];
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => MapScreen(
                                      camPos: LatLng(
                                        title['lat'],
                                        title['lng'],
                                      ),
                                    ),
                              ),
                            );
                          },
                          title: Text(title['title']),
                          subtitle: Text(
                            DateFormat(
                              'MMMM d, y h:mm a',
                            ).format(title['dateAdded'].toDate()),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  titleCtrl.text = title['title'];
                                  descCtrl.text = title['description'];
                                  dateCtrl.text = DateFormat(
                                    'MMMM d, y h:mm a',
                                  ).format(title['dateAdded'].toDate());
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
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Title",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              TextField(
                                                controller: titleCtrl,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                "Description",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              TextField(
                                                controller: descCtrl,
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                "Date",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              TextField(
                                                controller: dateCtrl,
                                                readOnly: true,

                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  suffixIcon: IconButton(
                                                    onPressed: () async {
                                                      date =
                                                          await showDatePicker(
                                                            context: context,
                                                            firstDate: DateTime(
                                                              1950,
                                                            ),
                                                            lastDate:
                                                                DateTime.now()
                                                                    .add(
                                                                      Duration(
                                                                        days: 7,
                                                                      ),
                                                                    ),
                                                          );

                                                      if (date != null) {
                                                        dateCtrl
                                                            .text = DateFormat(
                                                          'MMMM d, y h:mm a',
                                                        ).format(date!);
                                                      }
                                                      setState(() {});
                                                    },
                                                    icon: Icon(
                                                      Icons.calendar_month,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Center(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('places')
                                                        .doc(title.id)
                                                        .update({
                                                          'title':
                                                              titleCtrl.text,
                                                          'description':
                                                              descCtrl.text,
                                                          'dateAdded': date!,
                                                        });
                                                    setState(() {});
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Edit"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  );
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  QuickAlert.show(
                                    text:
                                        "Are you sure you want to delete this?",
                                    title: "Delete",
                                    context: context,
                                    type: QuickAlertType.warning,
                                    confirmBtnText: "Yes",
                                    cancelBtnText: "No",
                                    showCancelBtn: true,
                                    onConfirmBtnTap: () async {
                                      await FirebaseFirestore.instance
                                          .collection('places')
                                          .doc(title.id)
                                          .delete();
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    },
                                  );
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
