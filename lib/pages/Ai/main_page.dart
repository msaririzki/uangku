import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mob3_uas_klp_02/pages/Ai/variable_umum.dart';

class AiPage extends StatefulWidget {
  // Konstruktor untuk AiPage
  const AiPage({Key? key}) : super(key: key);

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  // Kontroler untuk TextField
  TextEditingController textEditingController = TextEditingController();
  String answer = ''; // Menyimpan jawaban dari AI
  XFile? image; // Menyimpan gambar yang dipilih
  bool isLoading = false; // Status loading saat mengirim permintaan
  bool showHistory = false; // Status untuk menampilkan riwayat
  List<Map<String, String>> history =
      []; // Menyimpan riwayat pertanyaan dan jawaban

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green, Colors.yellow], // Warna gradien
            ),
          ),
        ),
        title: const Center(child: Text('WELCOME TO AI UANGKU')),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Mengubah status untuk menampilkan atau menyembunyikan riwayat
              setState(() {
                showHistory = !showHistory;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Ketik apa yang anda mau', // Placeholder
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Mengubah posisi bayangan
                      ),
                    ],
                    color: image == null
                        ? Color.fromARGB(255, 255, 255, 255)
                        : null,
                    image: image != null
                        ? DecorationImage(
                            image: FileImage(File(image!.path)),
                            fit: BoxFit.cover)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      _pickImage, // Memanggil fungsi untuk memilih gambar
                  child: const Text('Ambil/Unggah Gambar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Warna latar belakang
                    foregroundColor: Colors.white, // Warna teks
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                image != null
                    ? ElevatedButton(
                        onPressed: () {
                          // Menghapus gambar yang dipilih
                          setState(() {
                            image = null;
                          });
                        },
                        child: const Text('Hapus Gambar'),
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            if (image == null) {
                              return Colors.transparent;
                            } else {
                              return Colors.blue;
                            }
                          }),
                        ),
                      )
                    : const SizedBox(),
                ElevatedButton(
                  onPressed: () {
                    // Mengirim permintaan ke model AI
                    setState(() {
                      isLoading = true; // Mengubah status loading
                    });

                    GenerativeModel model = GenerativeModel(
                        model: 'gemini-1.5-flash-latest', apiKey: apiKey);
                    model.generateContent([
                      Content.multi([
                        TextPart(textEditingController.text),
                        if (image != null)
                          DataPart(
                              'image/jpeg', File(image!.path).readAsBytesSync())
                      ]),
                    ]).then((value) => setState(() {
                          answer = _cleanAnswer(value.text.toString());
                          history.add({
                            'question': textEditingController.text,
                            'answer': answer,
                          });
                          isLoading = false; // Mengubah status loading
                        }));
                  },
                  child: isLoading
                      ? CircularProgressIndicator() // Menampilkan indikator loading
                      : const Text('Kirim'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Warna latar belakang
                    foregroundColor: Colors.white, // Warna teks
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(answer), // Menampilkan jawaban
              ],
            ),
          ),
          if (showHistory)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Menyembunyikan riwayat saat area di luar riwayat ditekan
                  setState(() {
                    showHistory = false;
                  });
                },
                child: Container(
                  color: Colors.black54, // Warna latar belakang riwayat
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      color: Colors.white,
                      child: ListView(
                        padding: EdgeInsets.all(20),
                        children: history
                            .map((entry) => ListTile(
                                  title: Text('Q: ${entry['question']}'),
                                  subtitle: Text('A: ${entry['answer']}'),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    // Mengambil gambar dari kamera atau galeri
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                setState(() {
                  image = pickedFile; // Menyimpan gambar yang dipilih
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Ambil dari Galeri'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                setState(() {
                  image = pickedFile; // Menyimpan gambar yang dipilih
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _cleanAnswer(String answer) {
    // Menghapus karakter khusus dari jawaban
    return answer.replaceAll(RegExp(r'\*\*'), '').trim();
  }
}
