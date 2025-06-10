import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticketing_app/firebase_options.dart';
import 'pages/ticket_list.dart'; // Buat file ini di folder 'pages'

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticketing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const OnboardingPage(),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32), // Agak lebih besar
              Center(
                child: Image.asset(
                  'assets/images/image.png',
                  width: 160, // Agak lebih besar
                  height: 200, // Agak lebih besar
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 28), // Agak lebih besar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26, // Agak lebih besar
                ),
                child: Container(
                  padding: const EdgeInsets.all(22), // Agak lebih besar
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18), // Agak lebih besar
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10, // Agak lebih besar
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Ticketing App',
                        style: TextStyle(
                          fontSize: 20, // Agak lebih besar
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12), // Agak lebih besar
                      Text(
                        'Membantu anda untuk managemen pembelian Tiket agar lebih efisien',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13, // Agak lebih besar
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                          letterSpacing: 0,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 18), // Agak lebih besar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TicketListPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              0,
                              17,
                              255,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14, // Agak lebih besar
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                22,
                              ), // Agak lebih besar
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 15, // Agak lebih besar
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32), // Agak lebih besar
            ],
          ),
        ),
      ),
    );
  }
}
