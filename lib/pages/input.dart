/// Screen untuk input transaksi baru
/// Menampilkan form input data transaksi keuangan
/// 
/// Fitur:
/// - Form input lengkap (tanggal, kategori, keterangan, nominal)
/// - Validasi input
/// - Toggle kategori pemasukan/pengeluaran
/// - Format nominal otomatis
/// - Loading state
/// - Error handling

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mob3_uas_klp_02/bloc/category/category_bloc.dart';
import 'package:mob3_uas_klp_02/bloc/laporan/laporan_bloc.dart';
import 'package:mob3_uas_klp_02/models/laporan_model.dart';
import 'package:mob3_uas_klp_02/widget/button_select.dart';
import 'package:mob3_uas_klp_02/widget/date_field.dart';
import 'package:mob3_uas_klp_02/widget/elevated_button.dart';
import 'package:mob3_uas_klp_02/widget/number_field.dart';
import 'package:mob3_uas_klp_02/widget/select_field.dart';
import 'package:mob3_uas_klp_02/widget/templete.dart';
import 'package:mob3_uas_klp_02/widget/text_field.dart';

class Input extends StatelessWidget {
  const Input({super.key});

  @override
  Widget build(BuildContext context) {
    // Load daftar kategori pemasukan saat pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(GetCategoryEvent(category: 'Pemasukan'));
    });

    // Key untuk validasi form
    final formKey = GlobalKey<FormState>();
    
    // Variable untuk menyimpan kategori yang dipilih
    late String category;
    
    // Controller untuk input fields
    final TextEditingController dateController = TextEditingController();
    final TextEditingController keteranganController = TextEditingController();
    final TextEditingController nominalController = TextEditingController();

    return Scaffold(
        body: Templete(
      content: Form(
          key: formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
            // Judul form
            Text(
              'Form input data',
              style: Theme.of(context)
                  .primaryTextTheme
                  .displayLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Deskripsi form dengan tanda wajib (*)
            RichText(
              text: TextSpan(
                style: Theme.of(context).primaryTextTheme.displayMedium,
                children: const [
                  TextSpan(
                    text: 'Isi form ini untuk menginput laporan keuangan. Tanda',
                  ),
                  TextSpan(
                    text: ' * ',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextSpan(
                    text: 'wajib di isi',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Toggle Pemasukan/Pengeluaran
            const ButtonSelect(
              options: ['Pemasukan', 'Pengeluaran'],
              getCategory: true,
            ),
            const SizedBox(height: 15),

            // Form input dengan state management
            BlocConsumer<LaporanBloc, LaporanState>(
              // Handler untuk state changes
              listener: (context, state) {
                if (state is LaporanSuccess) {
                  // Tampilkan pesan sukses
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                } else if (state is LaporanError) {
                  // Tampilkan pesan error
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              // Builder untuk UI
              builder: (context, state) {
                // Tampilkan loading indicator
                if (state is LaporanLoading) {
                  return const Column(children: [
                    SizedBox(height: 50.0),
                    Center(child: CircularProgressIndicator()),
                  ]);
                }

                return Column(
                  children: [
                    // Input tanggal dengan validasi
                    FormDate(
                        labelText: 'Tanggal *',
                        hintText: '',
                        controller: dateController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tanggal tidak boleh kosong';
                          }
                          DateTime selectedDate =
                              DateFormat('dd-MM-yyyy').parse(value);
                          if (selectedDate.isAfter(DateTime.now())) {
                            return 'Transaksi tidak boleh dilakukan di masa depan';
                          }
                          return null;
                        }),
                    const SizedBox(height: 15),

                    // Dropdown pilihan kategori
                    BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryError) {
                          return Text(state.message);
                        } else if (state is CategoryLoaded) {
                          // Siapkan list nama kategori
                          List<String> categoryNames = state.categories
                              .map((category) => category.name)
                              .toList();
                          category =
                              categoryNames.isNotEmpty ? categoryNames.first : '';

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Dropdown kategori
                                FormSelect(
                                  list: categoryNames,
                                  onChanged: (String? value) {
                                    category = value!;
                                  },
                                ),
                                // Pesan jika belum ada kategori
                                if (categoryNames.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      'Buat kategori dahulu!',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                              ]);
                        }
                        return const Center();
                      },
                    ),
                    const SizedBox(height: 15),

                    // Input keterangan (opsional)
                    FormText(
                      labelText: 'Keterangan',
                      hintText: '',
                      required: false,
                      controller: keteranganController,
                    ),
                    const SizedBox(height: 15),

                    // Input nominal dengan format currency
                    FormNumber(
                      labelText: 'Nominal *',
                      hintText: '',
                      currency: true,
                      controller: nominalController,
                      inputActionDone: true,
                    ),
                    const SizedBox(height: 30),

                    // Tombol submit
                    ButtonElevated(
                        text: "Simpan Data",
                        onPress: () {
                          if (formKey.currentState!.validate()) {
                            // Parse tanggal dari string
                            DateTime dateTime = DateFormat('dd-MM-yyyy')
                                .parse(dateController.text);
                            // Parse nominal dari string dengan format currency
                            int nominalInt = int.parse(nominalController.text
                                .replaceAll(RegExp(r'[^0-9]'), ''));

                            // Buat model laporan
                            final model = LaporanModel(
                                nominal: nominalInt,
                                keterangan: keteranganController.text,
                                categoryName: category,
                                tanggal: dateTime,
                                createdAt: DateTime.now());

                            // Trigger event create laporan
                            context
                                .read<LaporanBloc>()
                                .add(CreateLaporanEvent(model: model));

                            // Reset form
                            dateController.clear();
                            keteranganController.clear();
                            nominalController.clear();
                          }
                        })
                  ],
                );
              }),
          ])),
    ));
  }
}
