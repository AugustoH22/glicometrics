import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/primeiro_acesso/tela_dados.dart';

class TelaBemVindo extends StatefulWidget {
  const TelaBemVindo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TelaBemVindoState createState() => _TelaBemVindoState();
}

class _TelaBemVindoState extends State<TelaBemVindo> {
  final FirestoreService _firestoreService = FirestoreService();
  String nome = 'Nome';

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }
  
  Future<void> _buscarDados() async {
    var dadosPessoais = await _firestoreService.getDadosPessoais();

    setState(() {
      nome = dadosPessoais?['nome'] ?? 'Nome';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Bem-vindo!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                nome,
                style: const TextStyle(fontSize: 24, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaDadosPessoais(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Continuar",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
