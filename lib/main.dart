import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main/autentificacao/auth_screen.dart';
import 'package:main/core/env.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/primeiro_acesso/tela_bem_vindo.dart';
import 'package:main/tela_conta/tela_conta.dart';
import 'package:main/tela_home/tela_home.dart';
import 'package:main/tela_receita/tela_receita.dart';
import 'package:main/tela_registros/tela_registros.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase/firebase_options.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('pt_BR', null);

  Gemini.init(apiKey: Env.apiKey); // Substitua pela sua chave de API
  runApp(const GlicoMetricsApp());
}

class GlicoMetricsApp extends StatelessWidget {
  const GlicoMetricsApp({super.key});

  Future<bool> _fetchAceitaTermos() async {
    final FirestoreService firebaseService = FirestoreService();
    var docAceitaTermos = await firebaseService.getAceitaTermos();
    return docAceitaTermos?['aceita'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return FutureBuilder<bool>(
              future: _fetchAceitaTermos(),
              builder: (context, aceitaSnapshot) {
                if (aceitaSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (aceitaSnapshot.hasError) {
                  return const Center(child: Text("Erro ao carregar termos."));
                } else {
                  final aceitaTermos = aceitaSnapshot.data ?? false;
                  if (aceitaTermos) {
                    return const MainScreen();
                  } else {
                    return const TelaBemVindo();
                  }
                }
              },
            );
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          HomeScreen(),
          ReceitaScreen(),
          RegistrosScreen(),
          ContaScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 5,
        selectedLabelStyle: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 0), // Esconde textos não selecionados
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_sharp, size: 30),
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home_sharp, size: 30),
                Text(
                  'Home',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 69, 133, 228),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.utensils, size: 26),
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(FontAwesomeIcons.utensils, size: 28),
                Text(
                  'Receitas',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 69, 133, 228),
                    fontWeight: FontWeight.bold,
                ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined, size: 26),
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bar_chart_outlined, size: 28),
                Text(
                  'Registros',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 69, 133, 228),
                    fontWeight: FontWeight.bold,
                ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle_sharp, size: 26),
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_rounded, size: 30),
                Text(
                  'Minha Conta',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 69, 133, 228),
                    fontWeight: FontWeight.bold,
                ),
                ),
              ],
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 69, 133, 228),
        unselectedItemColor: const Color.fromARGB(255, 128, 129, 131),
        onTap: _onItemTapped,
      ),
    );
  }
}
