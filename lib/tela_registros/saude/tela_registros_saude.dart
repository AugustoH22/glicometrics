import 'package:flutter/material.dart';
import 'package:main/tela_registros/saude/tela_peso.dart';
import 'package:main/tela_registros/saude/tela_pressao.dart';

class SaudeScreen extends StatelessWidget {
  const SaudeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dados de Saúde'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Adiciona o círculo com a régua no centro
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.straighten, size: 40, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              // Texto principal
              const Text(
                'Adicionar Medições',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Subtexto
              const Text(
                'Qual medição você quer adicionar?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              // Botões
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PesoScreen()),
                  );
                },
                icon: const Icon(Icons.monitor_weight),
                label: const Text('Peso'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  minimumSize: const Size(250, 50), // Define o tamanho fixo dos botões
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PressaoArterialScreen()),
                  );
                },
                icon: const Icon(Icons.favorite),
                label: const Text('Pressão Arterial'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  minimumSize: const Size(250, 50), // Mesmo tamanho do botão de Peso
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

