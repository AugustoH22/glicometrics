import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(60.0), // Define a altura do AppBar
          child: AppBar(
            title: const Text(
              'GlicoMetrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontFamily: 'Lemonada',
                fontWeight: FontWeight.w300,
                height: 0,
              ),
            ),
            backgroundColor: Colors.transparent, // Cor de fundo transparente
            elevation: 0, // Sem sombra
            flexibleSpace: Container(
              decoration: ShapeDecoration(
                color: const Color(0xFF1693A5),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Ação para notificações
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: 348,
                  height: 457,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: Colors.black.withOpacity(0.20000000298023224),
                      ),
                      borderRadius: BorderRadius.circular(43),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 5,
                        offset: Offset(4, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Center(
                    child: SimpleBarChart.withSampleData(),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  color: Colors.green[50],
                  child: const Center(
                    child: Text('Receitas'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  color: Colors.yellow[50],
                  child: const Center(
                    child: Text('Banco de Alimentos'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  color: Colors.red[50],
                  child: const Center(
                    child: Text('Registros'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series<OrdinalSales, String>> seriesList;
  final bool animate;

  const SimpleBarChart(this.seriesList, {super.key, required this.animate});

  /// Cria um gráfico com dados de exemplo.
  factory SimpleBarChart.withSampleData() {
    return SimpleBarChart(
      _createSampleData(),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
    );
  }

  /// Dados de exemplo
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = [
      OrdinalSales('2014', 5),
      OrdinalSales('2015', 25),
      OrdinalSales('2016', 100),
      OrdinalSales('2017', 75),
    ];

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Sales',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Classe para armazenar dados do gráfico
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
