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

  MedicoesWidget({
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
    List<Map<String, dynamic>> sortedPressao =
        List.from(ultimasPressao as Iterable);
    sortedPressao.sort(
        (a, b) => (a['data'] as DateTime).compareTo(b['data'] as DateTime));

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
        const SizedBox(height: 20),
        const SizedBox(height: 16),

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
          child: ultimasPressao!.isEmpty
              ? const Center(child: Text('Sem dados de pressão arterial'))
              : Column(
                  children: [
                    // Exibe a última medição de Sistólica e Diastólica no topo
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Sistólica',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              Text(
                                '${ultimaPressao?['sistolica'] ?? 'N/A'}',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'mmHg',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Diastólica',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              Text(
                                '${ultimaPressao?['diastolica'] ?? 'N/A'}',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'mmHg',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SfCartesianChart(
                          margin: const EdgeInsets.all(
                              0), // Reduz a margem ao redor do gráfico
                          plotAreaBorderWidth: 0,
                          primaryXAxis: CategoryAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                            labelRotation: -45,
                            labelIntersectAction:
                                AxisLabelIntersectAction.multipleRows,
                            labelStyle: const TextStyle(
                              fontSize: 9,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: 240,
                            interval: 40,
                          ),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries>[
                            // Série para as barras de pressão arterial
                            RangeColumnSeries<Map<String, dynamic>, String>(
                              dataSource: sortedPressao,
                              xValueMapper:
                                  (Map<String, dynamic> data, int index) {
                                DateTime dateTime = data['data'] as DateTime;
                                // ignore: prefer_interpolation_to_compose_strings
                                return DateFormat('dd/MM').format(dateTime) +
                                    '\n' +
                                    DateFormat('HH:mm').format(dateTime);
                              },
                              lowValueMapper: (Map<String, dynamic> data, _) =>
                                  data['diastolica'],
                              highValueMapper: (Map<String, dynamic> data, _) =>
                                  data['sistolica'],
                              name: 'Pressão',
                              color: Colors.green,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              width: 0.3,
                              pointColorMapper:
                                  (Map<String, dynamic> data, int index) =>
                                      colors[index % colors.length],
                            ),
                            // Série de pontos transparentes para exibir os valores sistólica
                            ScatterSeries<Map<String, dynamic>, String>(
                              dataSource: sortedPressao,
                              xValueMapper: (Map<String, dynamic> data, _) =>
                                  DateFormat('dd/MM\nHH:mm')
                                      .format(data['data']),
                              yValueMapper: (Map<String, dynamic> data, _) =>
                                  data['sistolica']?.toDouble(),
                              markerSettings: const MarkerSettings(
                                isVisible: true,
                                color: Colors.transparent,
                                width: 0,
                                height: 0,
                              ),
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.top,
                                builder: (data, point, series, pointIndex,
                                    seriesIndex) {
                                  return Text(
                                    '${data['sistolica']}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Série de pontos transparentes para exibir os valores diastólica
                            ScatterSeries<Map<String, dynamic>, String>(
                              dataSource: sortedPressao,
                              xValueMapper: (Map<String, dynamic> data, _) =>
                                  DateFormat('dd/MM\nHH:mm')
                                      .format(data['data']),
                              yValueMapper: (Map<String, dynamic> data, _) =>
                                  data['diastolica']?.toDouble(),
                              markerSettings: const MarkerSettings(
                                isVisible: true,
                                color: Colors.transparent,
                                width: 0,
                                height: 0,
                              ),
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.bottom,
                                builder: (data, point, series, pointIndex,
                                    seriesIndex) {
                                  return Text(
                                    '${data['diastolica']}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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
