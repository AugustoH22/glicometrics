import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:main/firebase/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firebaseService = FirestoreService();

  List<Map<String, dynamic>> _historicoRegistros = [];
  Map<String, double> _nutricaoDoDia = {
    'calorias': 0,
    'carboidratos': 0,
    'proteinas': 0,
    'gorduras': 0,
  };
  List<Map<String, dynamic>> _medicoesGlicemia = [];
  Map<String, dynamic>? _ultimoPeso;
  Map<String, dynamic>? _ultimaPressao;
  List<Map<String, dynamic>> _refeicoesDoDia = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  // Função para buscar os dados do Firestore
  Future<void> _buscarDados() async {
    DateTime hoje = DateTime.now();
    _historicoRegistros = await firebaseService.getHistoricoRegistros();
    _nutricaoDoDia = await firebaseService.getTotalNutricaoDoDia(hoje);
    _medicoesGlicemia = await firebaseService.getMedicoesGlicemia();
    _ultimoPeso = await firebaseService.buscarUltimoPeso();
    _ultimaPressao = await firebaseService.getUltimoRegistroPressao();
    _refeicoesDoDia = await firebaseService.getRefeicoesDoDia();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildGraficosLinha(),
                      const SizedBox(height: 20),
                      const Text(
                        'Minhas Medições',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildMedicoes(),
                      const SizedBox(height: 20),
                      const Text(
                        'Meus Registros',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildHistoricoRegistros(),
                      const SizedBox(height: 20),
                      const Text(
                        'Minhas Refeições',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildRefeicoes(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Função para construir o AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('GlicoMetrics'),
    );
  }

  // Função para construir os gráficos na parte superior (glicemia e nutrição)
  Widget _buildGraficosLinha() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: _medicoesGlicemia.isEmpty
                  ? const Text('Sem dados de glicemia')
                  : SimpleBarChart.withSampleData(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: _buildGraficoNutricional(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraficoNutricional() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Nutrição do Dia',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 150, // Definir a altura para o gráfico
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Calorias');
                          case 1:
                            return const Text('Carboidratos');
                          case 2:
                            return const Text('Proteínas');
                          case 3:
                            return const Text('Gorduras');
                        }
                        return const Text('');
                      }),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toString());
                      }),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey, width: 1),
              ),
              minX: 0,
              maxX: 3,
              minY: 0,
              maxY: _getMaxValue(),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, _nutricaoDoDia['calorias'] ?? 0),
                    FlSpot(1, _nutricaoDoDia['carboidratos'] ?? 0),
                    FlSpot(2, _nutricaoDoDia['proteinas'] ?? 0),
                    FlSpot(3, _nutricaoDoDia['gorduras'] ?? 0),
                  ],
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Função auxiliar para calcular o valor máximo no gráfico (eixo Y)
  double _getMaxValue() {
    double maxCalorias = _nutricaoDoDia['calorias'] ?? 0;
    double maxCarboidratos = _nutricaoDoDia['carboidratos'] ?? 0;
    double maxProteinas = _nutricaoDoDia['proteinas'] ?? 0;
    double maxGorduras = _nutricaoDoDia['gorduras'] ?? 0;

    return [maxCalorias, maxCarboidratos, maxProteinas, maxGorduras]
        .reduce((a, b) => a > b ? a : b);
  }

  // Função para construir a seção de medições (glicemia, peso, pressão arterial)
  Widget _buildMedicoes() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 100,
                color: Colors.green[50],
                child: Center(
                  child: _medicoesGlicemia.isNotEmpty
                      ? Text(
                          'Última Glicemia: ${_medicoesGlicemia.first['valor']} mg/dL')
                      : const Text('Sem dados de glicemia'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 100,
                color: Colors.yellow[50],
                child: Center(
                  child: _ultimoPeso != null
                      ? Text('Peso: ${_ultimoPeso!['peso']} kg')
                      : const Text('Sem dados de peso'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 100,
          color: Colors.red[50],
          child: Center(
            child: _ultimaPressao != null
                ? Text(
                    'Pressão: ${_ultimaPressao!['sistolica']}/${_ultimaPressao!['diastolica']} mmHg')
                : const Text('Sem dados de pressão arterial'),
          ),
        ),
      ],
    );
  }

  // Função para construir o histórico de registros
  Widget _buildHistoricoRegistros() {
    return _historicoRegistros.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _historicoRegistros.length,
            itemBuilder: (context, index) {
              var registro = _historicoRegistros[index];
              return ListTile(
                title: Text('${registro['tipo']} - ${registro['hora']}'),
                subtitle: Text(
                    'Data: ${registro['data'].toString().substring(0, 10)}'),
                trailing: Text(registro['tipo'] == 'Pressão Arterial'
                    ? '${registro['sistolica']}/${registro['diastolica']} mmHg'
                    : registro['tipo'] == 'Peso'
                        ? '${registro['peso']} kg'
                        : '${registro['valor']} mg/dL'),
              );
            },
          )
        : const Text('Sem registros disponíveis.');
  }

  // Função para construir a seção de refeições do dia
  Widget _buildRefeicoes() {
    return _refeicoesDoDia.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _refeicoesDoDia.length,
            itemBuilder: (context, index) {
              var refeicao = _refeicoesDoDia[index];
              return ListTile(
                title: Text('Refeição: ${refeicao['nome']}'),
                subtitle: Text(
                    'Hora: ${refeicao['hora']} - Calorias: ${refeicao['calorias']} kcal'),
              );
            },
          )
        : const Text('Sem refeições registradas');
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

  /// Dados de exemplo para o gráfico de glicemia
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = [
      OrdinalSales('Seg', 120),
      OrdinalSales('Ter', 140),
      OrdinalSales('Qua', 110),
      OrdinalSales('Qui', 100),
    ];

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Glicemia',
        domainFn: (OrdinalSales sales, _) => sales.day,
        measureFn: (OrdinalSales sales, _) => sales.glicemia,
        data: data,
      )
    ];
  }
}

class OrdinalSales {
  final String day;
  final int glicemia;

  OrdinalSales(this.day, this.glicemia);
}
