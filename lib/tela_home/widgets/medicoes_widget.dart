import 'package:flutter/material.dart';

class MedicoesWidget extends StatelessWidget {
  final double pesoAtual;
  final double maiorPeso;
  final double menorPeso;
  final double imc;
  final double altura;
  final Map<String, dynamic>? ultimaPressao;
  final VoidCallback alterarAltura;

  const MedicoesWidget({
    super.key,
    required this.pesoAtual,
    required this.maiorPeso,
    required this.menorPeso,
    required this.imc,
    required this.altura,
    required this.alterarAltura,
    this.ultimaPressao,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        // Peso Atual, Maior Peso, e Menor Peso
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPesoItem(menorPeso, "Menor Peso"),
                  _buildPesoItem(pesoAtual, "Atual"),
                  _buildPesoItem(maiorPeso, "Maior Peso"),
                ],
              ),
              const SizedBox(height: 16),

              // Exibição do valor do IMC e classificação
              Text(
                imc.toStringAsFixed(1),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // Classificação do IMC
              Text(
                _getIMCClassificacao(imc),
                style: const TextStyle(fontSize: 16, color: Colors.orange),
              ),
              const SizedBox(height: 16),

              // Barra de IMC
              _buildBarraIMC(context, imc),
              const SizedBox(height: 16),

              // Container para a altura
              InkWell(
                onTap: alterarAltura,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${altura.toInt()} cm",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Pressão Arterial
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: ultimaPressao != null
                ? Text(
                    'Pressão: ${ultimaPressao!['sistolica']}/${ultimaPressao!['diastolica']} mmHg')
                : const Text('Sem dados de pressão arterial'),
          ),
        ),
      ],
    );
  }

  // Widget para exibir o item de peso
  Widget _buildPesoItem(double valor, String label) {
    return Column(
      children: [
        Text(
          valor.toStringAsFixed(1),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  // Barra de IMC com gradiente de cores e indicador
  Widget _buildBarraIMC(BuildContext context, double imc) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.red
              ],
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Positioned(
          left: ((imc - 15) / (40 - 15)) * MediaQuery.of(context).size.width * 0.8,
          child: const Icon(Icons.arrow_drop_down, color: Colors.black, size: 20),
        ),
      ],
    );
  }

  // Função para definir a classificação do IMC
  String _getIMCClassificacao(double imc) {
    if (imc < 18.5) return "Abaixo do Peso";
    if (imc < 24.9) return "Peso Normal";
    if (imc < 29.9) return "Sobrepeso";
    return "Obesidade";
  }
}
