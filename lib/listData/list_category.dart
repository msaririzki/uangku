/// Widget untuk menampilkan item kategori dalam bentuk list
/// dengan tombol edit dan hapus
/// 
/// Fitur:
/// - Menampilkan nama kategori
/// - Tombol edit untuk mengubah nama kategori
/// - Tombol hapus untuk menghapus kategori
/// - Garis pembatas antar item

import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_02/widget/dialog.dart';

class ListCategory extends StatelessWidget {
  // Properties untuk data kategori
  final String uid;          // ID unik kategori
  final String name;         // Nama kategori
  final String category;     // Jenis kategori (Pemasukan/Pengeluaran)

  const ListCategory({
    super.key,
    required this.uid,
    required this.name,
    required this.category
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nama kategori di sebelah kiri
          Text(
            name,
            style: Theme.of(context).primaryTextTheme.displayMedium,
          ),
          // Tombol aksi di sebelah kanan
          Row(
            children: [
              // Tombol edit
              IconButton(
                onPressed: () {
                  DialogWidget.editCategory(context, uid, name, category);
                },
                icon: const Icon(Icons.edit_outlined),
              ),
              // Tombol hapus
              IconButton(
                onPressed: () {
                  DialogWidget.deleteCategory(context, uid, category);
                },
                icon: const Icon(Icons.delete_outlined),
              ),
            ],
          ),
        ],
      ),
      // Garis pembatas antar item
      const Divider(
        color: Colors.black54,
        thickness: 1,
        height: 20,
      ),
    ]);
  }
}
