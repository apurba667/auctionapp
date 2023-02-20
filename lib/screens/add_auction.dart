import 'dart:io';

import 'package:auctionapp/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddAuction extends StatefulWidget {
  const AddAuction({Key? key}) : super(key: key);

  @override
  State<AddAuction> createState() => _AddAuctionState();
}

class _AddAuctionState extends State<AddAuction> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.text;
    _descriptionController.text;
    _priceController.text;
    // TODO: implement dispose
    super.dispose();
  }

  // peaking Photo from Gallery
  XFile? _auctionProductImage;

  chooseImageFromGC() async {
    ImagePicker _picker = ImagePicker();
    _auctionProductImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  //for date and time
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  //adding all information to firebase
  String? imageUrl;
  late FirebaseAuth _auth;
  late User? _user;
  late Stream<User?> _authStateChanges;

  addingDatatoFirebase()async{

    File imageFile = File(_auctionProductImage!.path);
    FirebaseStorage _storage = FirebaseStorage.instance;
    UploadTask _uploadTask =  _storage.ref("products").child(_auctionProductImage!.name).putFile(imageFile);
    TaskSnapshot snapshot = await _uploadTask;
    imageUrl = await snapshot.ref.getDownloadURL();

    CollectionReference _products = FirebaseFirestore.instance.collection("products");
    _products.add({
      "product_name":_nameController.text,
      "product_description": _descriptionController.text,
      "Bid_price":_priceController.text,
      "img":imageUrl,
      "year": date.year,
      "month":date.month,
      "day":date.day,
      "time_hour": time.hour,
      "time_minute":time.minute
    });
    // for gatting user id
    await Future.delayed(Duration(seconds: 2));
    _auth = FirebaseAuth.instance;
    _authStateChanges = _auth.authStateChanges();
    _authStateChanges.listen((User? user) {
      CollectionReference _userProducts = FirebaseFirestore.instance.collection("${user!.uid}");
      _userProducts.add({
        "product_name":_nameController.text,
        "product_description": _descriptionController.text,
        "Bid_price":_priceController.text,
        "img":imageUrl,
        "year": date.year,
        "month":date.month,
        "day":date.day,
        "time_hour": time.hour,
        "time_minute":time.minute
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    final hours = time.hour.toString().padLeft(2, "0");
    final minutes = time.minute.toString().padLeft(2, "0");
    return Container(
      height: 700,
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22), topRight: Radius.circular(22))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            CustomTextField(
                controller: _nameController,
                hintText: "Enter Product Name",
                isPass: false),
            SizedBox(
              height: 20,
            ),
            CustomTextField(
                controller: _descriptionController,
                hintText: "Enter Product Description",
                isPass: false),
            SizedBox(
              height: 20,
            ),
            CustomTextField(
                controller: _priceController,
                hintText: "Enter Minimum Bid Price,",
                isPass: false),
            SizedBox(
              height: 20,
            ),
            Text(
              "Pick a Product Photo:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: _auctionProductImage == null
                  ? IconButton(
                      onPressed: () {
                        chooseImageFromGC();
                        setState(() {

                        });
                      },
                      icon: Icon(Icons.photo),
                    )
                  : Image.file(
                      File(_auctionProductImage!.path),
                      height: 250,
                      width: 250,
                      fit: BoxFit.fill,
                    ),
            ),
            Row(children: [ElevatedButton(
                onPressed: () async {
                  DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2090));

                  if (newDate == null) return;
                  setState(() {
                    date = newDate;
                  });
                },
                child: Text("Select Date")),
              SizedBox(width: 10,),
            Text("${date.year}/${date.month}/${date.day}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
            ],),

           Row(children: [
             ElevatedButton(
                 onPressed: () async {
                   TimeOfDay? newTime =
                   await showTimePicker(context: context, initialTime: time);
                   if (newTime == null) return;
                   setState(() {
                     time = newTime;
                   });
                 },
                 child: Text("Select Time")),
             SizedBox(width: 10,),
             Text(
               "${hours}:${minutes}",
               style: TextStyle(fontSize: 30),
             ),
           ],),
            SizedBox(height: 10,),
            Center(child: ElevatedButton(onPressed: (){
              addingDatatoFirebase();
              Navigator.of(context).pop();
            }, child: Text("Add Product")))
          ],
        ),
      ),
    );
  }
}