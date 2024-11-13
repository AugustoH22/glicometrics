// ignore_for_file: library_private_types_in_public_api

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/tela_home/widgets/graficos_linha.dart';
import 'package:main/tela_home/widgets/historico_registro.dart';
import 'package:main/tela_home/widgets/medicoes_widget.dart';
import 'package:main/tela_home/widgets/refeicoes_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firebaseService = FirestoreService();
  
  // Variáveis para armazenar os dados
  List<Map<String, dynamic>> _historicoRegistros = [];
  List<Map<String, dynamic>> _data = [];
  Map<String, double>? _pesoData;
  List<Map<String, dynamic>> _nutricaoDoDia = [];
  Map<String, dynamic>? _ultimaPressao;
  List<Map<String, dynamic>> _refeicoesDoDia = [];
  List<FlSpot> glicemiaSpots = [];
  List<Map<String, dynamic>> _ultimasPressao = [];
  double pesoAtual = 0;
  double maiorPeso = 0;
  double menorPeso = 0;
  double altura = 170;
  double imc = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  Future<void> _buscarDados() async {
    DateTime hoje = DateTime.now();
    _historicoRegistros = await firebaseService.getHistoricoRegistros();
    _nutricaoDoDia = await firebaseService.getTotalNutricaoPorPeriodo(hoje);
    _ultimaPressao = await firebaseService.getUltimoRegistroPressao();
    _refeicoesDoDia = await firebaseService.getRefeicoesDoDia();
    _data = await firebaseService.fetchGlicemiaUltimos30Dias();
    _pesoData = await firebaseService.getPesoData();
    _ultimasPressao = await firebaseService.getUltimasMedicoesPressao();
    
    List<FlSpot> spots = _data.map((entry) {
      DateTime data = entry['data'];
      double valorGlicemia = entry['valor'];
      double x = data.difference(DateTime.now().subtract(const Duration(days: 30))).inDays.toDouble();
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
      appBar: AppBar(
        title: const Text('GlicoMetrics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minhas Medições',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    GraficosLinha(nutrientesPorDia: _nutricaoDoDia, glicemiaSpots: glicemiaSpots),
                    MedicoesWidget(
                      pesoAtual: pesoAtual,
                      maiorPeso: maiorPeso,
                      menorPeso: menorPeso,
                      imc: imc,
                      altura: altura,
                      alterarAltura: _alterarAltura,
                      ultimaPressao: _ultimaPressao,
                      ultimasPressao: _ultimasPressao,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Meus Registros',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    HistoricoRegistros(historicoRegistros: _historicoRegistros),
                    const SizedBox(height: 20),
                    const Text(
                      'Minhas Refeições',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    RefeicoesWidget(refeicoesDoDia: _refeicoesDoDia),
                  ],
                ),
              ),
            ),
    );
  }

  // Função para alterar a altura e recalcular o IMC
  void _alterarAltura() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                const Text("Altura", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    ).whenComplete(() => setState(() => imc = pesoAtual / ((altura / 100) * (altura / 100))));
  }
}
