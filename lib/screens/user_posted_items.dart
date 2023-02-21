import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class UserPostedItems extends StatefulWidget {
  const UserPostedItems({Key? key}) : super(key: key);

  @override
  State<UserPostedItems> createState() => _UserPostedItemsState();
}

class _UserPostedItemsState extends State<UserPostedItems> {
  final Stream<QuerySnapshot> productStream =
      FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).snapshots();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(

        stream: productStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Something Wrong!"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Container(
                height: 200,
                child: Card(
                  elevation: 200,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: FancyShimmerImage(
                            imageUrl: data["img"],
                          )),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data["product_name"]),
                                Text(data["product_description"]),
                                Text(
                                    "Last Bid Date: ${data["day"]}/${data["month"]}/${data["year"]}"),
                                Text(
                                    "Last Bid Time: ${data["time_hour"]}:${data["time_minute"]}"),
                                Text("Bid Price:${data["Bid_price"]}\$"),
                                ElevatedButton(
                                    onPressed: () {}, child: Text("Bid Now"))
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
