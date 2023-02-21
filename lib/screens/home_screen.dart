import 'package:auctionapp/screens/add_auction.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Stream<QuerySnapshot> productStream =
      FirebaseFirestore.instance.collection("products").snapshots();

  addNewAuction() {
    return showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => AddAuction());
  }
  updateAuction(documentID,data)async{
    var bidData = data["Bid_price"];
    var newBidData = int.parse(bidData);
    var newBidDataAdd = newBidData+20;
    var collection = FirebaseFirestore.instance.collection('products');
    collection.doc("${documentID.toString()}").update({
      "Bid_price": newBidDataAdd.toString()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewAuction();
        },
        child: Icon(Icons.add),
      ),
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
                                Text(
                                  data["product_name"],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                                //  Text(data["product_description"]),

                                // Text(
                                //    "Last Bid Time: ${data["time_hour"]}:${data["time_minute"]}"),
                                Text(
                                  "Bid Price:${data["Bid_price"]}\$",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Last Bid Date: ${data["day"]}/${data["month"]}/${data["year"]}",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),

                                ElevatedButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        backgroundColor: Colors.cyan,
                                          context: context,
                                          builder: (document) {
                                            return Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Container(
                                                  height: 800,
                                                  color: Colors.cyan,
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex:1,
                                                          child:
                                                              FancyShimmerImage(
                                                        imageUrl: data["img"],
                                                        height: 300,
                                                        width: 300,boxFit: BoxFit.fill,
                                                      )),
                                                      Expanded(
                                                          flex: 1,
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [

                                                              Text(
                                                                data["product_name"],
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 22),
                                                              ),
                                                              Text(data["product_description"],style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.bold),),
                                                            Text(
                                                                 "Last Bid Time: ${data["time_hour"]}:${data["time_minute"]}",style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.bold),),
                                                              Text(
                                                                "Bid Price:${data["Bid_price"]}\$",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.bold),
                                                              ),
                                                              Text(
                                                                "Last Bid Date: ${data["day"]}/${data["month"]}/${data["year"]}",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.bold),
                                                              ),
                                                                ElevatedButton(onPressed: (){
                                                                  updateAuction(document,data);
                                                                }, child: Text("Place Bid"))

                                                      ],),
                                                          ))
                                                    ],
                                                  )),
                                            );
                                          });
                                    },
                                    child: Text("Bid Now"))
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
