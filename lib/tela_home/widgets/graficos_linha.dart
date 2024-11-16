import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        const SizedBox(height: 16),
        Text(
          'Glicemia',
          style: GoogleFonts.cookie(fontSize: 30),
        ),
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
                                    style: GoogleFonts.cookie(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  Text(
                                    'mg/dL',
                                    style: GoogleFonts.cookie(
                                        color: Colors.black, fontSize: 12),
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
                                style: GoogleFonts.cookie(
                                    color: Colors.black, fontSize: 14),
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
        const SizedBox(height: 16),
        // Gráfico de Nutrição
        // Gráfico de Nutrição dos últimos 7 dias
        Text(
          'Alimentação',
          style: GoogleFonts.cookie(fontSize: 30),
        ),
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
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10.0, // margem à esquerda
              right: 10.0, // margem à direita
              top: 20.0, // margem no topo
              bottom: 5.0, // margem na parte inferior
            ),
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: GoogleFonts.cookie(),
              ),
              primaryYAxis: NumericAxis(
                name: 'Calorias',
                title: AxisTitle(text: 'Calorias (kcal)', textStyle: GoogleFonts.cookie()),
                labelStyle: GoogleFonts.cookie(),
                opposedPosition: false,
                interval: 100,
                minimum: 0,
              ),
              axes: [
                NumericAxis(
                  name: 'Nutrientes',
                  title: AxisTitle(text: 'Nutrientes (g)', textStyle: GoogleFonts.cookie()),
                  labelStyle: GoogleFonts.cookie(),
                  opposedPosition: true,
                  interval: 20,
                  minimum: 0,
                ),
              ],
              legend: Legend(isVisible: true, position: LegendPosition.bottom, textStyle: GoogleFonts.cookie()),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries>[
                // Série de Calorias, associada ao eixo "Calorias"
                LineSeries<Map<String, dynamic>, String>(
                  
                  dataSource: nutrientesPorDia.reversed.toList(),
                  xValueMapper: (Map<String, dynamic> data, _) =>
                      _getFormattedDate((data['data'] as DateTime)),
                  yValueMapper: (Map<String, dynamic> data, _) =>
                      data['calorias'] ?? 0,
                  yAxisName: 'Calorias',
                  name: 'Cal.',
                  color: Colors.red,
                ),
                // Série de Carboidratos, associada ao eixo "Nutrientes"
                LineSeries<Map<String, dynamic>, String>(
                  dataSource: nutrientesPorDia.reversed.toList(),
                  xValueMapper: (Map<String, dynamic> data, _) =>
                      _getFormattedDate((data['data'] as DateTime)
                          .add(const Duration(days: 1))),
                  yValueMapper: (Map<String, dynamic> data, _) =>
                      data['carboidratos'] ?? 0,
                  yAxisName: 'Nutrientes',
                  name: 'Carb.',
                  color: Colors.blue,
                ),
                // Série de Proteínas, associada ao eixo "Nutrientes"
                LineSeries<Map<String, dynamic>, String>(
                  dataSource: nutrientesPorDia.reversed.toList(),
                  xValueMapper: (Map<String, dynamic> data, _) =>
                      _getFormattedDate((data['data'] as DateTime)),
                  yValueMapper: (Map<String, dynamic> data, _) =>
                      data['proteinas'] ?? 0,
                  yAxisName: 'Nutrientes',
                  name: 'Prot.',
                  color: Colors.green,
                ),
                // Série de Gorduras, associada ao eixo "Nutrientes"
                LineSeries<Map<String, dynamic>, String>(
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
        ),
      ],
    );
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
