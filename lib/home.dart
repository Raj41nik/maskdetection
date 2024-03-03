import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loading = true;
  late File _image;
  late List _output;
  final imagepicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  detectimage(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _output = prediction!;
      loading = false;
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    super.dispose();
  }

  pickimage_camera() async {
    var image = await imagepicker.getImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  pickimage_gallery() async {
    var image = await imagepicker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }




  @override
  Widget build(BuildContext context) {
    var h=MediaQuery.of(context).size.height;
    var w=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('ML Classifier',style: GoogleFonts.roboto(),),
      ),
      body: Container(
        height: h,
        width: w,
        //color: Colors.red,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

           Container(
             height: 180,
             width: 180,
             padding: EdgeInsets.all(10),
             //color: Colors.greenAccent,
             child: Image.asset('assets/mask.png'),
           ),
            Container(
              child: Text('ML Classifier',style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 15,),
            Container(
              width: double.infinity,
              height: 50,
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () {
                 pickimage_camera();
                },
                child: Text('Camera',style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.bold),
                )
              ),),
            SizedBox(height: 15,),
            Container(
              width: double.infinity,
              height: 50,
              child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: () {
                    pickimage_gallery();
                  },
                  child: Text('Gallery',style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.bold),
                  )
              ),),
            loading != true
                ? Container(
                 child: Column(
                   children: [
                  Container(
                    height: 220,
                    // width: double.infinity,
                    padding: EdgeInsets.all(15),
                    child: Image.file(_image),
                  ),
                  _output != null ? Text((_output[0]['label']).toString().substring(2),
                          style: GoogleFonts.roboto(fontSize: 18))
                      : Text(''),
                  _output != null
                      ? Text('Confidence: ' + (_output[0]['confidence']).toString(),
                      style: GoogleFonts.roboto(fontSize: 18))
                      : Text('')
                ],
              ),
            )
                : Container(),

          ],

        ),
      ),
    );
  }
}


