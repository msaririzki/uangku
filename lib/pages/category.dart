/// Screen untuk menampilkan dan mengelola kategori transaksi
/// Menampilkan daftar kategori pemasukan dan pengeluaran
/// 
/// Fitur:
/// - Tampilan daftar kategori
/// - Toggle antara kategori pemasukan dan pengeluaran
/// - Loading state dengan skeleton
/// - Error handling
/// - Maksimal 6 kategori per jenis

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mob3_uas_klp_02/bloc/category/category_bloc.dart';
import 'package:mob3_uas_klp_02/listData/list_category.dart';
import 'package:mob3_uas_klp_02/widget/button_select.dart';
import 'package:mob3_uas_klp_02/widget/templete.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Categorys extends StatelessWidget {
  const Categorys({super.key});

  @override
  Widget build(BuildContext context) {
    // Load data kategori pemasukan saat pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(GetCategoryEvent(category: 'Pemasukan'));
    });

    // List skeleton loader untuk animasi loading
    final List<Widget> skeletonLoaders = List.generate(
      6,
      (index) => const Skeletonizer(
        enabled: true,
        child: ListCategory(
          name: 'skeleton',
          uid: '',
          category: '',
        ),
      ),
    );

    return Templete(
        withScrollView: true,
        content: Column(
          children: [
            // Tombol toggle antara Pemasukan dan Pengeluaran
            const ButtonSelect(
              options: ['Pemasukan', 'Pengeluaran'],
              getCategory: true,
            ),
            const SizedBox(height: 20),

            // Consumer untuk menangani state changes
            BlocListener<CategoryBloc, CategoryState>(
              listener: (context, state) {
                if (state is CategorySuccess) {
                  // Tampilkan pesan sukses
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                } else if (state is CategoryError) {
                  // Tampilkan pesan error
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              // Builder untuk UI
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  // Tampilkan skeleton loader saat loading
                  if (state is CategoryLoading) {
                    return Column(children: skeletonLoaders);
                  } 
                  // Tampilkan daftar kategori
                  else if (state is CategoryLoaded) {
                    return state.categories.isEmpty
                        // Tampilan jika tidak ada kategori
                        ? const Center(
                            child: Text(
                            'Category belum tersedia',
                            style: TextStyle(
                                color: Colors.black45, fontSize: 20.0),
                          ))
                        // List kategori yang tersedia
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: state.categories.length,
                            itemBuilder: (context, index) {
                              final category = state.categories[index];
                              return ListCategory(
                                uid: category.uid!,
                                name: category.name,
                                category: category.category,
                              );
                            },
                          );
                  } 
                  // State default
                  else {
                    return const Center();
                  }
                },
              ),
            )
          ],
        ));
  }
}
