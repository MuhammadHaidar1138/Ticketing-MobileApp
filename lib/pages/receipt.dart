import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptPage extends StatefulWidget {
  final String namaTiket;
  final String kategori;
  final int harga;
  final DateTime tanggalPembelian;

  const ReceiptPage({
    super.key,
    required this.namaTiket,
    required this.kategori,
    required this.harga,
    required this.tanggalPembelian,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool _showNotif = false;

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _downloadReceiptAsPdf() async {
    final pdf = pw.Document();

    // Simpan data ke variabel lokal agar tidak error di closure PDF
    final namaTiket = widget.namaTiket;
    final kategori = widget.kategori;
    final harga = widget.harga;
    final tanggal = widget.tanggalPembelian;
    final total = _formatCurrency(harga);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Bukti Pembayaran',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Nama Tiket: $namaTiket',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Kategori: $kategori',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Tanggal: ${tanggal.day}-${tanggal.month}-${tanggal.year}',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Total Pembayaran: $total',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Terima kasih telah melakukan pembayaran.',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bukti_Pembayaran.pdf',
    );

    // Tampilkan notifikasi setelah download
    setState(() {
      _showNotif = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showNotif = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Bukti Pembayaran',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15, // Lebih kecil
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 14.0,
        ), // Lebih kecil
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_showNotif)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10), // Lebih kecil
                margin: const EdgeInsets.only(bottom: 14), // Lebih kecil
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8), // Lebih kecil
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Bukti pembayaran berhasil diunduh!',
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Kartu bukti pembayaran
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14), // Lebih kecil
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // Lebih kecil
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 6, // Lebih kecil
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE7F0FF),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: Color(0xFF3468E7),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pembayaran Berhasil',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transaksi kamu telah selesai. Detail pembelian ada di bawah ini.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8), // Lebih kecil
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F0FF),
                      borderRadius: BorderRadius.circular(6), // Lebih kecil
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama tiket & tipe tiket di kiri, harga di kanan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.namaTiket,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.kategori,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _formatCurrency(widget.harga),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Total pembayaran
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pembayaran',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _formatCurrency(widget.harga),
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3468E7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Divider(color: Color(0xFFBDBDBD), thickness: 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3468E7),
                          side: const BorderSide(color: Color(0xFF3468E7)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(90, 36), // Lebih kecil
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                        ),
                        child: Text(
                          'Kembali',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3468E7),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _downloadReceiptAsPdf();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3468E7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(90, 36), // Lebih kecil
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                        ),
                        child: Text(
                          'Unduh bukti',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
