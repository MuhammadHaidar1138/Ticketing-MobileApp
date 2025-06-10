import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'receipt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatelessWidget {
  final String namaTiket;
  final String kategori;
  final int harga;
  final DateTime tanggalPembelian;

  const PaymentPage({
    super.key,
    required this.namaTiket,
    required this.kategori,
    required this.harga,
    required this.tanggalPembelian,
  });

  String _formatDate(DateTime date) {
    final Map<int, String> monthNames = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'Mei',
      6: 'Jun',
      7: 'Jul',
      8: 'Agu',
      9: 'Sep',
      10: 'Okt',
      11: 'Nov',
      12: 'Des',
    };
    return '${date.day} ${monthNames[date.month]} ${date.year}';
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _savePurchaseToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('purchase').add({
        'nama_tiket': namaTiket,
        'kategori': kategori,
        'harga': harga,
        'tanggal': tanggalPembelian,
        'created_at': FieldValue.serverTimestamp(),
      });
      // Debug log
      print('Data berhasil disimpan ke Firestore');
    } catch (e) {
      print('Gagal menyimpan ke Firestore: $e');
      // Bisa juga tampilkan snackbar jika mau
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 20,
          ), // Icon lebih kecil
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pembayaran',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15, // Lebih kecil
            height: 1,
            letterSpacing: -0.95,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Total Tagihan
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon Total Tagihan
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FF),
                          borderRadius: BorderRadius.circular(8), // Lebih kecil
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.receipt_long,
                            color: Color(0xFF3468E7),
                            size: 18, // Lebih kecil
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Tagihan',
                            style: GoogleFonts.poppins(
                              fontSize: 11, // Lebih kecil
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(harga),
                            style: GoogleFonts.poppins(
                              fontSize: 18, // Lebih kecil
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama Pesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 11, // Lebih kecil
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '$namaTiket - $kategori',
                        style: GoogleFonts.poppins(
                          fontSize: 11, // Lebih kecil
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal',
                        style: GoogleFonts.poppins(
                          fontSize: 11, // Lebih kecil
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        _formatDate(tanggalPembelian),
                        style: GoogleFonts.poppins(
                          fontSize: 11, // Lebih kecil
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Pilih Metode Pembayaran Section
            Text(
              'Pilih Metode Pembayaran',
              style: GoogleFonts.poppins(
                fontSize: 13, // Lebih kecil
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Metode Pembayaran Options
            _buildPaymentOption(
              context: context,
              title: 'Tunai (Cash)',
              icon: Icons.wallet,
              iconColor: const Color(0xFF34A853),
              onTap: () {
                _showCashPaymentDialog(context);
              },
              fontSize: 13, // Tambahkan parameter fontSize
              iconSize: 20,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              context: context,
              title: 'Kartu Kredit',
              icon: Icons.credit_card,
              iconColor: const Color(0xFF4285F4),
              onTap: () {
                _showCreditCardPaymentDialog(context);
              },
              fontSize: 13,
              iconSize: 20,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              context: context,
              title: 'QRIS / QR Pay',
              icon: Icons.qr_code_2,
              iconColor: const Color(0xFFEA4335),
              onTap: () {
                _showQrisPaymentPopup(context);
              },
              fontSize: 13,
              iconSize: 20,
            ),
            const SizedBox(height: 14),

            // Punya Pertanyaan? Section
            Text(
              'Punya pertanyaan?',
              style: GoogleFonts.poppins(
                fontSize: 11, // Lebih kecil
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10), // Lebih kecil
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // Lebih kecil
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.help_outline,
                    color: Color(0xFF3468E7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hubungi Admin untuk bantuan pembayaran.',
                      style: GoogleFonts.poppins(
                        fontSize: 11, // Lebih kecil
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    double fontSize = 16,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ), // Lebih kecil
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Lebih kecil
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  void _showCashPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Lebih kecil
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: 220, // Lebih kecil
            padding: const EdgeInsets.all(14), // Lebih kecil
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pembayaran Tunai',
                      style: GoogleFonts.poppins(
                        fontSize: 13, // Lebih kecil
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3468E7),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/images/tunai.png',
                    width: 70,
                    height: 70,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pembayaran Tunai',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Jika pembayaran telah diterima, klik button konfirmasi pembayaran untuk menyelesaikan transaksi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () async {
                    await _savePurchaseToFirestore();
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ReceiptPage(
                              namaTiket: namaTiket,
                              kategori: kategori,
                              harga: harga,
                              tanggalPembelian: tanggalPembelian,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3468E7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size(double.infinity, 36), // Lebih kecil
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Konfirmasi Pembayaran',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreditCardPaymentDialog(BuildContext context) {
    final TextEditingController cardNumberController = TextEditingController(
      text: '8810 7766 1234 9876',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pembayaran Kartu Kredit',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3468E7),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/images/kredit.png',
                    width: 70,
                    height: 70,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cardNumberController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: cardNumberController.text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nomor Kartu Kredit Disalin!'),
                            ),
                          );
                        },
                        child: Text(
                          'Salin',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3468E7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Transfer Pembayaran',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pastikan nominal dan tujuan pembayaran sudah benar sebelum melanjutkan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () async {
                    await _savePurchaseToFirestore();
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ReceiptPage(
                              namaTiket: namaTiket,
                              kategori: kategori,
                              harga: harga,
                              tanggalPembelian: tanggalPembelian,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3468E7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size(double.infinity, 36),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Konfirmasi Pembayaran',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQrisPaymentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Lebih kecil
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Pembayaran QRIS',
                      style: GoogleFonts.poppins(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                QrImageView(
                  data: 'https://gopay.co.id/merchant/qris',
                  version: QrVersions.auto,
                  size: 110.0, // Lebih kecil
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  errorStateBuilder: (cxt, err) {
                    return Container(
                      width: 110.0,
                      height: 110.0,
                      alignment: Alignment.center,
                      child: Text(
                        'Oops! Gagal memuat QR Code.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.0),
                Text(
                  'Scan QR untuk Membayar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6.0),
                Text(
                  'Gunakan aplikasi e-wallet atau mobile banking untuk scan QR di atas dan selesaikan pembayaran',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _savePurchaseToFirestore();
                      Navigator.of(dialogContext).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ReceiptPage(
                                namaTiket: namaTiket,
                                kategori: kategori,
                                harga: harga,
                                tanggalPembelian: tanggalPembelian,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3468E7),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: Text(
                      'Konfirmasi Pembayaran',
                      style: GoogleFonts.poppins(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
