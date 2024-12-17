/// File ini berisi implementasi CategoryBloc yang menangani logika manajemen kategori
/// menggunakan BLoC (Business Logic Component) pattern.
/// 
/// CategoryBloc mengelola:
/// - Pembuatan kategori baru
/// - Pengambilan daftar kategori
/// - Pembaruan kategori
/// - Penghapusan kategori
/// - Validasi input kategori

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:mob3_uas_klp_02/models/category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'category_event.dart';
part 'category_state.dart';

/// CategoryBloc adalah kelas utama yang mengimplementasikan BLoC pattern untuk manajemen kategori.
/// Kelas ini menangani semua event terkait kategori dan mengubah state sesuai hasil prosesnya.
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  // Instance Firestore untuk akses database
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  // Instance UUID untuk generate ID unik
  final Uuid uuid = const Uuid();

  CategoryBloc() : super(CategoryInitial()) {
    /// Handler untuk GetCategoryEvent
    /// Event ini dipanggil untuk mengambil daftar kategori berdasarkan jenisnya
    /// (Pemasukan/Pengeluaran)
    on<GetCategoryEvent>((event, emit) async {
      emit(CategoryLoading());

      try {
        await _loadCategories(event.category, emit);
      } catch (e) {
        emit(CategoryError(message: e.toString()));
      }
    });

    /// Handler untuk CreateCategoryEvent
    /// Menangani pembuatan kategori baru dengan validasi:
    /// - Nama kategori tidak boleh kosong
    /// - Nama kategori harus unik
    /// - Jumlah kategori tidak boleh lebih dari 6
    on<CreateCategoryEvent>((event, emit) async {
      emit(CategoryLoading());

      final String userId = await getIdUser();

      // Validasi nama kategori
      if (event.model.name.isEmpty ||
          event.model.name.toString() == '' ||
          event.model.name.toString() == 'Kosong') {
        emit(CategoryError(message: 'Nama kategori tidak boleh kosong.'));
        await _loadCategories(event.model.category.toString(), emit);
        return;
      }

      // Cek jumlah kategori yang sudah ada
      final AggregateQuerySnapshot queryCount = await fireStore
          .collection("category")
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: event.model.category.toString())
          .count()
          .get();

      // Cek apakah nama kategori sudah digunakan
      final QuerySnapshot cekUniqueName = await fireStore
          .collection("category")
          .where('userId', isEqualTo: userId)
          .where('name ', isEqualTo: event.model.name)
          .get();

      if (cekUniqueName.docs.isNotEmpty) {
        emit(CategoryError(message: 'Nama kategori sudah dipakai.'));
        await _loadCategories(event.model.category.toString(), emit);
        return;
      }

      // Cek batas maksimal kategori
      if (queryCount.count! >= 6) {
        emit(CategoryError(message: 'Jumlah kategori sudah mencapai batas.'));
        await _loadCategories(event.model.category.toString(), emit);
        return;
      }

      try {
        // Generate ID unik untuk kategori baru
        final String generateUid = uuid.v4();
        // Simpan kategori ke Firestore
        fireStore.collection('category').doc(generateUid).set({
          'uid': generateUid,
          'userId': userId,
          'name': event.model.name.toString(),
          'category': event.model.category.toString()
        });

        emit(CategorySuccess(
            message:
                'Berhasil tambah kategori ${event.model.category.toString()}'));
        await _loadCategories(event.model.category.toString(), emit);
      } catch (e) {
        emit(CategoryError(message: e.toString()));
        await _loadCategories(event.model.category.toString(), emit);
      }
    });

    /// Handler untuk UpdateCategoryEvent
    /// Menangani pembaruan nama kategori dan memperbarui semua laporan terkait
    on<UpdateCategoryEvent>((event, emit) async {
      emit(CategoryLoading());

      final String userId = await getIdUser();

      // Ambil data kategori yang akan diupdate
      final updateData = fireStore.collection("category").doc(event.uid);
      final docSnapshot = await updateData.get();

      // Ambil semua laporan yang menggunakan kategori ini
      final QuerySnapshot children = await fireStore
          .collection("laporan")
          .where('userId', isEqualTo: userId)
          .where('categoryName', isEqualTo: docSnapshot['name'])
          .get();

      if (!docSnapshot.exists) {
        emit(CategoryError(message: 'Category not found.'));
        return;
      }

      try {
        // Gunakan transaction untuk memastikan konsistensi data
        await fireStore.runTransaction((transaction) async {
          // Update nama kategori
          transaction.update(updateData, {"name": event.name});

          // Update semua laporan yang menggunakan kategori ini
          for (var item in children.docs) {
            transaction.update(item.reference, {'categoryName': event.name});
          }
        });

        emit(CategorySuccess(message: 'Berhasil update kategori'));
        await _loadCategories(docSnapshot['category'], emit);
      } catch (e) {
        emit(CategoryError(message: e.toString()));
        await _loadCategories(docSnapshot['category'], emit);
      }
    });

    /// Handler untuk DestroyCategoryEvent
    /// Menangani penghapusan kategori dan semua laporan terkait
    on<DestroyCategoryEvent>((event, emit) async {
      emit(CategoryLoading());

      final String userId = await getIdUser();

      // Ambil data kategori yang akan dihapus
      final DocumentReference dataCategory =
          fireStore.collection("category").doc(event.uid);
      final DocumentSnapshot getDataCategory = await dataCategory.get();

      // Validasi keberadaan kategori
      if (!getDataCategory.exists) {
        emit(CategoryError(message: 'Kategori tidak ditemukan'));
        return;
      }

      // Ambil semua laporan yang menggunakan kategori ini
      final QuerySnapshot children = await fireStore
          .collection("laporan")
          .where('userId', isEqualTo: userId)
          .where('categoryName', isEqualTo: getDataCategory['name'])
          .get();

      try {
        // Gunakan transaction untuk menghapus kategori dan semua laporan terkait
        await fireStore.runTransaction((transaction) async {
          transaction.delete(dataCategory);

          // Hapus semua laporan yang menggunakan kategori ini
          for (var item in children.docs) {
            transaction.delete(item.reference);
          }
        });

        emit(CategorySuccess(message: 'Berhasil menghapus kategori'));
        await _loadCategories(event.category, emit);
      } catch (e) {
        emit(CategoryError(message: e.toString()));
        await _loadCategories(event.category, emit);
      }
    });
  }

  /// Fungsi helper untuk memuat daftar kategori
  /// Mengambil kategori berdasarkan jenis dan userId
  Future<void> _loadCategories(
      String category, Emitter<CategoryState> emit) async {
    final String userId = await getIdUser();
    try {
      // Ambil kategori dari Firestore
      final QuerySnapshot docRef = await fireStore
          .collection("category")
          .where('category', isEqualTo: category)
          .where('userId', isEqualTo: userId)
          .get();

      // Konversi data Firestore ke model CategoryModel
      final categories = docRef.docs.map((doc) {
        return CategoryModel(
          uid: doc.id,
          name: doc['name'],
          category: doc['category'],
        );
      }).toList();

      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  /// Fungsi helper untuk mendapatkan ID user dari SharedPreferences
  Future<String> getIdUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? '';
  }
}
