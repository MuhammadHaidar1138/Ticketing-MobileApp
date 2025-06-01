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
        title: Text(
          'Ticketing App',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600, // Weight 600
            fontSize: 18,              // Size 18px
            height: 1,                 // Line height 100%
            letterSpacing: -0.95,      // Letter spacing -0.95px
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
            } else if (error is TypeError && error.toString().contains('FirebaseException')) {
              errorMessage = "Kesalahan dalam memproses data Firebase di Web. Mohon coba lagi.";
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot doc = tickets[index];
                final data = doc.data() as Map<String, dynamic>;

                final String namaTiket = data['nama_tiket'] ?? 'Nama Tiket Tidak Ada';
                final String kategori = data['kategori'] ?? 'Kategori Tidak Ada';
                
                // --- Perubahan untuk penanganan harga (solusi TypeError sebelumnya) ---
                int harga;
                dynamic rawHarga = data['harga']; 

                if (rawHarga is int) {
                  harga = rawHarga;
                } else if (rawHarga is String) {
                  try {
                    harga = int.parse(rawHarga);
                  } catch (e) {
                    print("Error parsing harga (String to int): $e. Harga yang didapatkan: $rawHarga");
                    harga = 0;
                  }
                } else {
                  print("Tipe data harga tidak dikenal: $rawHarga. Defaulting to 0.");
                  harga = 0;
                }
                // --- Akhir perubahan penanganan harga ---

                // --- Pengambilan data tanggal dari Firestore ---
                final dynamic rawTanggal = data['tanggal'];
                DateTime tanggalPembelian;

                if (rawTanggal is Timestamp) {
                  tanggalPembelian = rawTanggal.toDate(); // Konversi Timestamp ke DateTime
                } else {
                  print("Warning: 'tanggal' field is missing or not a Timestamp. Using current date.");
                  tanggalPembelian = DateTime.now(); // Default ke tanggal sekarang jika tidak ada
                }
                // --- Akhir pengambilan data tanggal ---


                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Radius 16px
                  ),
                  child: SizedBox( // Mengatur ukuran Card secara eksplisit
                    width: 358,    // Width 358px
                    height: 112,   // Height 112px
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded( // Menggunakan Expanded untuk kolom teks agar mengambil sisa ruang
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
                              children: [
                                // Nama Tiket
                                Text(
                                  namaTiket,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Mencegah overflow
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                // Kategori (VIP/Reguler)
                                Text(
                                  kategori,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Mencegah overflow
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 8),
                                // Harga
                                Text(
                                  'Rp. ${harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
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
                                  builder: (context) => PaymentPage(
                                    namaTiket: namaTiket,
                                    kategori: kategori,
                                    harga: harga,
                                    tanggalPembelian: tanggalPembelian
                                  ),
                                ),
                              );
                              // --- Akhir perubahan Navigasi ---
                            },
                            icon: const Icon(Icons.shopping_cart, size: 18),
                            label: const Text('Beli'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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