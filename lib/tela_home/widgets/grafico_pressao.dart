import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class GraficoPressao extends StatelessWidget {
 
  final Map<String, dynamic>? ultimaPressao;
  final List<Map<String, dynamic>>? ultimasPressao;

  GraficoPressao({
    super.key,
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
        Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 300,
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
                              Text(
                                'Sistólica',
                                style: GoogleFonts.cookie(
                                    fontSize: 20, color: Colors.grey),
                              ),
                              Text(
                                '${ultimaPressao?['sistolica'] ?? 'N/A'}',
                                style: GoogleFonts.cookie(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'mmHg',
                                style: GoogleFonts.cookie(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Diastólica',
                                style: GoogleFonts.cookie(
                                    fontSize: 20, color: Colors.grey),
                              ),
                              Text(
                                '${ultimaPressao?['diastolica'] ?? 'N/A'}',
                                style: GoogleFonts.cookie(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'mmHg',
                                style: GoogleFonts.cookie(
                                    fontSize: 16, color: Colors.grey),
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
                            labelStyle: GoogleFonts.cookie(
                              fontSize: 12,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: 240,
                              interval: 40,
                              labelStyle: GoogleFonts.cookie(
                                fontSize: 12,
                              )),
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
                                    style: GoogleFonts.cookie(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
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
                                    style: GoogleFonts.cookie(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
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
}
