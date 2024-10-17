
import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';


class HipoglicemiaScreen extends StatelessWidget {
  const HipoglicemiaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFF98E674), // Cor de fundo similar ao verde
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Você deve ingerir agora:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Espaço entre o título e as instruções
            const Text(
              '1 copo de 200 ml refrigerante com açúcar\n'
              '1 colher de sopa de açúcar ou mel\n'
              '3 balas de caramelo ou açucaradas\n\n'
              'Espere 15 minutos e meça a glicemia novamente.',
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40), // Espaço antes do botão
            ElevatedButton(
              onPressed: () async {
                await firestoreService.salvarHipoglicemia();
                // ignore: use_build_context_synchronously
                Navigator.pop(context); // Fecha a tela ao clicar em "Entendi"
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Entendi',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
    }
  }