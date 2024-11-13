import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraficosLinha extends StatelessWidget {
  final List<Map<String, dynamic>> nutrientesPorDia;
  final List<FlSpot> glicemiaSpots;

  const GraficosLinha({
    super.key,
    required this.nutrientesPorDia,
    required this.glicemiaSpots,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gráfico de Glicemia
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 300,
          margin: const EdgeInsets.all(16),
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
          child: glicemiaSpots.isEmpty
              ? const Center(child: Text('Sem dados de glicemia'))
              : Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 40.0, 30.0, 0.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false), // Oculta as grades
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false), // Oculta o topo
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: false), // Oculta o lado direito
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            interval: 40,
                            getTitlesWidget: (value, _) {
                              if (value == 0) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 10),
                                  ),
                                  const Text(
                                    'mg/dL',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 10),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            interval: 5,
                            getTitlesWidget: (value, _) {
                              DateTime date = DateTime.now()
                                  .subtract(Duration(days: 30 - value.toInt()));
                              return Text(
                                "${date.day}/${date.month}",
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.black.withOpacity(0.3), width: 2),
                        ),
                      ),
                      minX: 0,
                      maxX: 30,
                      minY: 0,
                      maxY: 200,
                      lineBarsData: [
                        LineChartBarData(
                          spots: glicemiaSpots,
                          isCurved: true,
                          color: Colors.cyanAccent,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // Gráfico de Nutrição
        // Gráfico de Nutrição dos últimos 7 dias
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 300,
          margin: const EdgeInsets.all(16),
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
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              title: AxisTitle(text: 'Últimos 7 dias'),
            ),
            primaryYAxis: NumericAxis(
              name: 'Calorias',
              title: AxisTitle(text: 'Calorias (kcal)'),
              opposedPosition: false,
              interval: 100,
              minimum: 0,
            ),
            axes: [
              NumericAxis(
                name: 'Nutrientes',
                title: AxisTitle(text: 'Nutrientes (g)'),
                opposedPosition: true,
                interval: 20,
                minimum: 0,
              ),
            ],
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries>[
              // Série de Calorias, associada ao eixo "Calorias"
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: nutrientesPorDia.reversed.toList(),
                xValueMapper: (Map<String, dynamic> data, _) =>
                    _getFormattedDate((data['data'] as DateTime).add(const Duration(days: 1))),
                yValueMapper: (Map<String, dynamic> data, _) =>
                    data['calorias'] ?? 0,
                yAxisName: 'Calorias',
                name: 'Cal.',
                color: Colors.red,
              ),
              // Série de Carboidratos, associada ao eixo "Nutrientes"
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: nutrientesPorDia.reversed.toList(),
                xValueMapper: (Map<String, dynamic> data, _) =>
                    _getFormattedDate((data['data'] as DateTime).add(const Duration(days: 1))),
                yValueMapper: (Map<String, dynamic> data, _) =>
                    data['carboidratos'] ?? 0,
                yAxisName: 'Nutrientes',
                name: 'Carb.',
                color: Colors.blue,
              ),
              // Série de Proteínas, associada ao eixo "Nutrientes"
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: nutrientesPorDia.reversed.toList(),
                xValueMapper: (Map<String, dynamic> data, _) =>
                    _getFormattedDate((data['data'] as DateTime).add(const Duration(days: 1))),
                yValueMapper: (Map<String, dynamic> data, _) =>
                    data['proteinas'] ?? 0,
                yAxisName: 'Nutrientes',
                name: 'Prot.',
                color: Colors.green,
              ),
              // Série de Gorduras, associada ao eixo "Nutrientes"
              ColumnSeries<Map<String, dynamic>, String>(
                dataSource: nutrientesPorDia.reversed.toList(),
                xValueMapper: (Map<String, dynamic> data, _) =>
                    _getFormattedDate(data['data'] as DateTime),
                yValueMapper: (Map<String, dynamic> data, _) =>
                    data['gorduras'] ?? 0,
                yAxisName: 'Nutrientes',
                name: 'Gord.',
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Função para formatar a data para exibição no gráfico
  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}