import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool loader = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController iqamaNoController = TextEditingController();
  TextEditingController ibanNoController = TextEditingController();

  File? _selectedImage;

  Future<void> _getImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final cropper = ImageCropper();
      final croppedFile = await cropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = croppedFile;
        });
      }
    }
  }




  // ******************************
  Future<void> _generateAndSharePDF() async {
    setState(() {
      loader = true;
    });
    final pdf = pdfLib.Document();
    final image = pdfLib.MemoryImage(
      File(_selectedImage!.path).readAsBytesSync(),
    );

    pdf.addPage(
      pdfLib.Page(
        build: (context) {
          return pdfLib.Column(
            children: [
              // pdfLib.Container(
              //   height: 350,
              //   width: 300,
              //   child: ,
              // ),
              pdfLib.Image(image),
              pdfLib.SizedBox(height: 30),
              pdfLib.Column(
                crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
                children: [
                  pdfLib.Row(
                    mainAxisAlignment: pdfLib.MainAxisAlignment.start,
                    children: [
                      pdfLib.Text('Name:',
                          style: pdfLib.TextStyle(
                            fontSize: 26,
                            fontWeight: pdfLib.FontWeight.bold,
                          )),
                      pdfLib.SizedBox(width: 15),
                      pdfLib.Text(nameController.text,
                          style: pdfLib.TextStyle(
                            fontSize: 26,
                            letterSpacing: 1,
                            fontWeight: pdfLib.FontWeight.bold,
                          )),
                    ],
                  ),
                  pdfLib.SizedBox(height: 20),
                  pdfLib.Row(
                    mainAxisAlignment: pdfLib.MainAxisAlignment.start,
                    children: [
                      pdfLib.Text('Father Name:',
                          style: pdfLib.TextStyle(
                            fontSize: 26,

                            fontWeight: pdfLib.FontWeight.bold,
                          )),
                      pdfLib.SizedBox(width: 15),
                      pdfLib.Text(fNameController.text,
                          style: pdfLib.TextStyle(
                            fontSize: 26,
                            letterSpacing: 1,
                            fontWeight: pdfLib.FontWeight.bold,
                          )),
                    ],
                  ),
                  pdfLib.SizedBox(height: 20),
                  pdfLib.Row(
                    mainAxisAlignment: pdfLib.MainAxisAlignment.start,
                    children: [
                      pdfLib.Text('Phone No:',
                          style: pdfLib.TextStyle(
                            fontSize: 26,
                            fontWeight: pdfLib.FontWeight.bold,
                          )),
                      pdfLib.SizedBox(width: 15),
                      pdfLib.Text(iqamaNoController.text,
                          style: pdfLib.TextStyle(
                            fontSize: 26,
                            letterSpacing: 1,
                            fontWeight: pdfLib.FontWeight.bold,
                          )),
                    ],
                  ),
                  pdfLib.SizedBox(height: 20),
                  pdfLib.Row(
                    mainAxisAlignment: pdfLib.MainAxisAlignment.start,

                    children: [
                      pdfLib.Text('IBAN No:',
                          style: pdfLib.TextStyle(
                            fontSize: 26,
                            fontWeight: pdfLib.FontWeight.bold,
                          )),
                      pdfLib.SizedBox(width: 15),
                      pdfLib.Text(ibanNoController.text,
                          style: pdfLib.TextStyle(
                            fontSize: 26,
                            letterSpacing: 1,
                            fontWeight: pdfLib.FontWeight.bold,
                          )),
                    ],
                  ),
                ],
              )
            ],
          );
        },
      ),
    );

    final pdfFile = File('${(await getTemporaryDirectory()).path}/${nameController.text}.pdf');
    pdfFile.writeAsBytesSync(await pdf.save());

    // Share the generated PDF via WhatsApp
    Share.shareFiles([pdfFile.path], text: 'Check out this PDF');
    setState(() {
      loader = false;
    });

    // Delete the generated PDF after sharing if needed
    // pdfFile.delete();
  }


  //----------------------------------------


  @override
  void dispose() {
    nameController.dispose();
    fNameController.dispose();
    iqamaNoController.dispose();
    ibanNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                _selectedImage != null
                    ? Image.file(
                        File(_selectedImage!.path),
                        width: 200, // Set the desired width
                        height: 140, // Set the desired height
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.3,
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black)),
                        child: const Icon(
                          Icons.add_a_photo,
                          size: 50,
                        ),
                      ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        _getImageFromSource(ImageSource.gallery);
                      },
                      child: const Text(
                        'Select\nfrom Gallery',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        _getImageFromSource(ImageSource.camera);
                      },
                      child: const Text(
                        'Capture\nfrom Camera',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: TextField(
                          controller: nameController,
                          decoration:  InputDecoration(labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      SizedBox(
                        height: 50,
                        child: TextField(
                          controller: fNameController,
                          decoration:  InputDecoration(labelText: 'Father Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      SizedBox(
                        height: 50,
                        child: TextField(
                          controller: iqamaNoController,
                          decoration:  InputDecoration(labelText: 'Phone No',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      SizedBox(
                        height: 50,
                        child: TextField(
                          controller: ibanNoController,
                          decoration: InputDecoration(labelText: 'IBAN No',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                GestureDetector(
                  onTap: _generateAndSharePDF,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: loader ? const Center(
                        child: CircularProgressIndicator(),
                      ) : const Center(
                        child: Text('Share',
                         style: TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
                           color: Colors.black
                         ),),
                      )
                    ),

                  ),
                ),
                const SizedBox(height: 10,),
                GestureDetector(
                  onTap: (){
                    nameController.clear();
                    fNameController.clear();
                    iqamaNoController.clear();
                    ibanNoController.clear();
                    _selectedImage = null;
                    setState(() {

                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purple.shade100,
                          width: 2
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text('Clear',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black
                          ),),
                      ),
                    )

                  ),
                ),
                const SizedBox(height: 20,)

              ],
            ),
          ),
        ),
      ),
    );
  }

}
