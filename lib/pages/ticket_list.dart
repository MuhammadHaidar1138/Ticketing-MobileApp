// lib/ticket_list_page.dart atau lib/pages/ticket_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ticketing_app/services/firebase.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan ini diimport
import 'package:ticketing_app/pages/payment_page.dart'; // Import halaman pembayaran yang baru dibuat

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  final FirestoreService firestoreService = FirestoreService();

  get tanggalPembelian => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Ticketing App',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14, // Ukuran font lebih kecil
            height: 1,
            letterSpacing: -0.95,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTickets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            dynamic error = snapshot.error;
            String errorMessage = "Terjadi kesalahan yang tidak diketahui.";

            if (error is FirebaseException) {
              errorMessage = "Firebase Error: ${error.code} - ${error.message}";
            } else if (error is TypeError &&
                error.toString().contains('FirebaseException')) {
              errorMessage =
                  "Kesalahan dalam memproses data Firebase di Web. Mohon coba lagi.";
              print("Original Web TypeError: $error");
            } else {
              errorMessage = "Kesalahan: $error";
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tidak ada tiket."));
          } else {
            final tickets = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                8,
                8,
                8,
                8,
              ), // Padding lebih kecil
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot doc = tickets[index];
                final data = doc.data() as Map<String, dynamic>;

                final String namaTiket =
                    data['nama_tiket'] ?? 'Nama Tiket Tidak Ada';
                final String kategori =
                    data['kategori'] ?? 'Kategori Tidak Ada';

                // --- Perubahan untuk penanganan harga (solusi TypeError sebelumnya) ---
                int harga;
                dynamic rawHarga = data['harga'];

                if (rawHarga is int) {
                  harga = rawHarga;
                } else if (rawHarga is String) {
                  try {
                    harga = int.parse(rawHarga);
                  } catch (e) {
                    print(
                      "Error parsing harga (String to int): $e. Harga yang didapatkan: $rawHarga",
                    );
                    harga = 0;
                  }
                } else {
                  print(
                    "Tipe data harga tidak dikenal: $rawHarga. Defaulting to 0.",
                  );
                  harga = 0;
                }
                // --- Akhir perubahan penanganan harga ---

                // --- Pengambilan data tanggal dari Firestore ---
                final dynamic rawTanggal = data['tanggal'];
                DateTime tanggalPembelian;

                if (rawTanggal is Timestamp) {
                  tanggalPembelian =
                      rawTanggal.toDate(); // Konversi Timestamp ke DateTime
                } else {
                  print(
                    "Warning: 'tanggal' field is missing or not a Timestamp. Using current date.",
                  );
                  tanggalPembelian =
                      DateTime.now(); // Default ke tanggal sekarang jika tidak ada
                }
                // --- Akhir pengambilan data tanggal ---

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                  ), // Margin lebih kecil
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // Radius lebih kecil
                  ),
                  child: SizedBox(
                    width: 300, // Lebar card lebih kecil
                    height: 80, // Tinggi card lebih kecil
                    child: Padding(
                      padding: const EdgeInsets.all(
                        10.0,
                      ), // Padding lebih kecil
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Nama Tiket
                                Text(
                                  namaTiket,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14, // Font lebih kecil
                                  ),
                                  overflow:
                                      TextOverflow
                                          .ellipsis, // Mencegah overflow
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                // Kategori (VIP/Reguler)
                                Text(
                                  kategori,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11, // Font lebih kecil
                                    color: Colors.grey,
                                  ),
                                  overflow:
                                      TextOverflow
                                          .ellipsis, // Mencegah overflow
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                // Harga
                                Text(
                                  'Rp. ${harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12, // Font lebih kecil
                                    height: 1, // Line height 100%
                                    letterSpacing: 0, // Letter spacing 0%
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tombol "Beli"
                          ElevatedButton.icon(
                            onPressed: () {
                              // --- Perubahan untuk Navigasi ke PaymentPage ---
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PaymentPage(
                                        namaTiket: namaTiket,
                                        kategori: kategori,
                                        harga: harga,
                                        tanggalPembelian: tanggalPembelian,
                                      ),
                                ),
                              );
                              // --- Akhir perubahan Navigasi ---
                            },
                            icon: const Icon(
                              Icons.shopping_cart,
                              size: 14,
                            ), // Icon lebih kecil
                            label: const Text(
                              'Beli',
                              style: TextStyle(fontSize: 12),
                            ), // Font tombol lebih kecil
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  6,
                                ), // Radius tombol lebih kecil
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              minimumSize: const Size(
                                0,
                                32,
                              ), // Tinggi tombol lebih kecil
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
