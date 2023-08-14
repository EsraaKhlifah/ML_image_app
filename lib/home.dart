import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<File>? imageFile;
  File? _image;
  String result = '';
  ImagePicker? imagePicker;
  selectPhotoFromGallery() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassification();
    });
  }

  capturePhotoFromCamera() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassification();
    });
  }

  loadDataModelFile() async {
    String? output = await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    print(output);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    loadDataModelFile();
  }

  doImageClassification() async {
    var recognition = await Tflite.runModelOnImage(
        path: _image!.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.1,
        asynch: true);
    print(recognition!.length.toString());
    setState(() {
      result = '';
    });
    recognition.forEach((element) {
      setState(() {
        print(element.toString());
        result += element['label'] + '\n\n';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/img.png'), fit: BoxFit.cover)),
        child: Column(
          children: [
            const SizedBox(
              width: 100.0,
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 20.0,
              ),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: TextButton(
                      onPressed: selectPhotoFromGallery,
                      onLongPress: capturePhotoFromCamera,
                      child: Container(
                          margin: const EdgeInsets.only(
                            top: 30.0,
                            right: 35.0,
                            left: 18,
                          ),
                          child: _image != null
                              ? Image.file(
                                  _image!,
                                  height: 360.0,
                                  width: 400.0,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 140.0,
                                  height: 190.0,
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.black,
                                  ),
                                )),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 160.0,
            ),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Text(
                '$result',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 25.0,
                    color: Colors.pinkAccent,
                    backgroundColor: Colors.white60),
              ),
            )
          ],
        ),
      ),
    );
  }
}
