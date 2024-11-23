import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class GraficoPeso extends StatelessWidget {
  final double pesoAtual;
  final double maiorPeso;
  final double menorPeso;
  final double imc;
  final int altura;
  final VoidCallback alterarAltura;

  GraficoPeso({
    super.key,
    required this.pesoAtual,
    required this.maiorPeso,
    required this.menorPeso,
    required this.imc,
    required this.altura,
    required this.alterarAltura,
  });

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Peso Atual, Maior Peso, e Menor Peso
        Container(
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
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
                style: GoogleFonts.cookie(
                    fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // Classificação do IMC
              Text(
                _getIMCClassificacao(imc),
                style: GoogleFonts.cookie(fontSize: 20, color: Colors.orange),
              ),
              const SizedBox(height: 16),

              // Barra de IMC
              _buildBarraIMC(context, imc),
              const SizedBox(height: 16),

              // Container para a altura
              Row(
                children: [
                  Text(
                    "Altura:",
                    style: GoogleFonts.cookie(fontSize: 24),
                  ),
                  const Spacer(), // Adiciona espaço flexível entre os itens
                  InkWell(
                    onTap: alterarAltura,
                    child: Container(
                      height: 30,
                      width: 50,
                      alignment: Alignment
                          .center, // Centraliza o texto dentro do Container
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${altura.toInt()}",
                        style: GoogleFonts.cookie(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 5), // Espaço entre o Container e o texto "cm"
                  Text(
                    "cm",
                    style: GoogleFonts.cookie(fontSize: 24),
                  ),
                ],
              ),
            ],
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
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(label,
            style: TextStyle(fontSize: 18, color: Colors.grey)),
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
          left: ((imc - 15) / (40 - 15)) *
              MediaQuery.of(context).size.width *
              0.8,
          child:
              const Icon(Icons.arrow_drop_down, color: Colors.black, size: 20),
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
