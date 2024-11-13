import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';


class MedicoesWidget extends StatelessWidget {
  final double pesoAtual;
  final double maiorPeso;
  final double menorPeso;
  final double imc;
  final double altura;
  final Map<String, dynamic>? ultimaPressao;
  final VoidCallback alterarAltura;
  final List<Map<String, dynamic>>? ultimasPressao;

  const MedicoesWidget({
    super.key,
    required this.pesoAtual,
    required this.maiorPeso,
    required this.menorPeso,
    required this.imc,
    required this.altura,
    required this.alterarAltura,
    this.ultimaPressao,
    this.ultimasPressao,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
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
            border: Border.all(
              color: Colors.black.withOpacity(0.2),
              width: 1,
            ),
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
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${altura.toInt()} cm",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Container(
          height: 300,
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
            border: Border.all(
              color: Colors.black.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ultimaPressao!.isEmpty
              ? const Center(child: Text('Sem dados de pressão arterial'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(text: 'Hora'),
                      majorGridLines: const MajorGridLines(width: 0),
                      labelRotation: -45,
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(text: 'Pressão (mmHg)'),
                      minimum: 40,
                      maximum: 200,
                      interval: 20,
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries>[
                      RangeColumnSeries<Map<String, dynamic>, String>(
                        dataSource: ultimasPressao ?? [],
                        xValueMapper: (Map<String, dynamic> data, _) =>
                            DateFormat('H a', 'pt_BR').format(data['data']),
                        lowValueMapper: (Map<String, dynamic> data, _) =>
                            data['diastolica'],
                        highValueMapper: (Map<String, dynamic> data, _) =>
                            data['sistolica'],
                        name: 'Pressão',
                        color: Colors.green,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6)),
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: const TextStyle(fontSize: 10),
                          labelAlignment: ChartDataLabelAlignment.top,
                          builder: (dynamic data, dynamic point, dynamic series,
                              int pointIndex, int seriesIndex) {
                            return Column(
                              children: [
                                Text(
                                  '${point.high.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(
                                    height: 50), // Espaço entre os rótulos
                                Text(
                                  '${point.low.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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

