import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  Map<String, dynamic>? _ultimaPressao;
  List<Map<String, dynamic>> _refeicoesDoDia = [];
  List<Map<String, dynamic>> _data = [];
  List<FlSpot> glicemiaSpots = [];
  Map<String, double>? _pesoData;
  double pesoAtual = 0;
  double maiorPeso = 0;
  double menorPeso = 0;
  double altura = 170; // Altura inicial, pode ser alterada
  double imc = 0;

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
    _ultimaPressao = await firebaseService.getUltimoRegistroPressao();
    _refeicoesDoDia = await firebaseService.getRefeicoesDoDia();
    _data = await firebaseService.fetchGlicemiaUltimos30Dias();
    _pesoData = await firebaseService.getPesoData();

    if (_data.isEmpty) {
      print('Nenhum dado de glicemia foi recuperado.');
    } else {
      for (var entry in _data) {
        print('Data: ${entry['data']}, Valor: ${entry['valor']}');
      }
    }

    List<FlSpot> spots = _data.map((entry) {
      DateTime data = entry['data'];
      double valorGlicemia = entry['valor'];

      // Calcula a posição x como diferença de dias
      double x = data
          .difference(DateTime.now().subtract(const Duration(days: 30)))
          .inDays
          .toDouble();
      return FlSpot(x, valorGlicemia);
    }).toList();

    setState(() {
      _isLoading = false;
      glicemiaSpots = spots;
      pesoAtual = _pesoData?['pesoAtual'] ?? 0;
      maiorPeso = _pesoData?['maiorPeso'] ?? 0;
      menorPeso = _pesoData?['menorPeso'] ?? 0;
      imc = (pesoAtual / ((altura / 100) * (altura / 100)));
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
                      const Text(
                        'Gráficos',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Primeiro gráfico
          Container(
            width: MediaQuery.of(context).size.width *
                0.9, // 90% da largura da tela
            height: 300,
            margin: const EdgeInsets.all(16),
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
                  : _buildGraficoGlicemia(),
            ),
          ),
          const SizedBox(width: 10),

          // Segundo gráfico
          Container(
            width: MediaQuery.of(context).size.width *
                0.9, // 90% da largura da tela
            height: 300,
            margin: const EdgeInsets.all(16),
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
        ],
      ),
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
        Container(
          height: 100,
          margin: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: _medicoesGlicemia.isNotEmpty
                ? Text(
                    'Última Glicemia: ${_medicoesGlicemia.first['valor']} mg/dL')
                : const Text('Sem dados de glicemia'),
          ),
        ),
        const SizedBox(height: 10),
        // Peso Atual, Maior Peso e Menor Peso
        // IMC com barra colorida e altura ajustável
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
              // Linha com os itens de peso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPesoItem(pesoAtual, "Atual"),
                  _buildPesoItem(maiorPeso, "Maior Peso"),
                  _buildPesoItem(menorPeso, "Menor Peso"),
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
              _buildBarraIMC(),
              const SizedBox(height: 16),

              // Container para a altura
              InkWell(
                onTap: _alterarAltura,
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
          height: 100,
          margin: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 2.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.2),
              width: 1,
            ),
          ),
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

  Widget _buildGraficoGlicemia() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(0.0, 40.0, 30.0, 0.0),
      child: glicemiaSpots.isEmpty
          ? const Center(
              child: Text("Sem dados de glicemia",
                  style: TextStyle(color: Colors.black)))
          : LineChart(
              LineChartData(
                gridData: FlGridData(show: false), // Oculta as grades

                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Oculta o topo
                  ),
                  rightTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false), // Oculta o lado direito
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval:
                          40, // Intervalo dos valores de glicemia no eixo Y
                      getTitlesWidget: (value, _) {
                        if (value == 0) {
                          return const SizedBox
                              .shrink(); // Retorna um widget vazio para ocultar
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 10),
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
                        // Exibe a data no eixo X a cada 5 dias
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

                // Exibe apenas as bordas inferior e esquerda
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
    );
  }

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

  // Função para exibir a barra de IMC com o indicador de classificação
  Widget _buildBarraIMC() {
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

  // Função para alterar a altura
  void _alterarAltura() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                const Text("Altura",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Slider(
                  min: 150,
                  max: 200,
                  divisions: 50,
                  value: altura,
                  onChanged: (value) => setState(() => altura = value),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() =>
        setState(() => imc = pesoAtual / ((altura / 100) * (altura / 100))));
  }
}

class OrdinalSales {
  final String day;
  final int glicemia;

  OrdinalSales(this.day, this.glicemia);
}
