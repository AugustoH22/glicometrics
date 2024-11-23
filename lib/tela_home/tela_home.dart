// ignore_for_file: library_private_types_in_public_api

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/regua/simple_ruler_picker.dart';
import 'package:main/tela_home/widgets/graficos_linha.dart';
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
  int altura = 0;
  double imc = 0;
  
  bool isCm = true; // Unidade atual

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  Future<void> _buscarDados() async {
    DateTime hoje = DateTime.now();
    _nutricaoDoDia = await firebaseService.getTotalNutricaoPorPeriodo(hoje);
    _ultimaPressao = await firebaseService.getUltimoRegistroPressao();
    _refeicoesDoDia = await firebaseService.getRefeicoesDoDia();
    _data = await firebaseService.fetchGlicemiaUltimos30Dias();
    _pesoData = await firebaseService.getPesoData();
    _ultimasPressao = await firebaseService.getUltimasMedicoesPressao();

    var ultimaAltura = await firebaseService.getAltura();
    if (ultimaAltura != null) {
      setState(() {
        altura = ultimaAltura['altura'];
      });
    }

    List<FlSpot> spots = _data.map((entry) {
      DateTime data = entry['data'];
      double valorGlicemia = entry['valor'];
      double x = data
          .difference(DateTime.now().subtract(const Duration(days: 30)))
          .inDays
          .toDouble();
      return FlSpot(x, valorGlicemia);
    }).toList();

    setState(() {
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 255, 255), // Cor branca sólida
        elevation: 0, // Remove a sombra para evitar alteração de cor
        toolbarHeight: 100,
        title: LayoutBuilder(
          builder: (context, constraints) {
            double logoSize = constraints.maxWidth * 0.4;
            if (logoSize > 150) {
              logoSize = 150; // Limita o tamanho máximo da logo
            }
            return Image.asset(
              'lib/img/receitas_logo.png',
              height: logoSize,
              width: logoSize,
              fit: BoxFit.contain,
            );
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(              
                      children: [
                        const SizedBox(width: 15),
                        Icon(Icons.medical_information_rounded),
                        const SizedBox(width: 5),
                        Text(
                          ' Minhas Medições',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    GraficosLinha(
                        nutrientesPorDia: _nutricaoDoDia,
                        glicemiaSpots: glicemiaSpots),
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
                    Row(
                      children: [
                        const SizedBox(width: 15),
                        Icon(Icons.fastfood),
                        const SizedBox(width: 5),
                        Text(
                          ' Minhas Refeições',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
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
    int aux3 = altura;
    if(aux3 == 0){
      aux3 = 170;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Altura",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "${altura.toStringAsFixed(0)} cm",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SimpleRulerPicker(
                    minValue: 120, // Valor mínimo da altura
                    maxValue: 220, // Valor máximo da altura
                    initialValue: aux3, // Altura inicial
                    onValueChanged: (value) {
                      setState(() {
                        altura = value;
                      });
                    },
                    scaleLabelSize: 16, // Tamanho da fonte das labels
                    scaleBottomPadding: 8, // Padding inferior das labels
                    scaleItemWidth: 12, // Largura de cada item de escala
                    longLineHeight: 70, // Altura das linhas longas
                    shortLineHeight: 35, // Altura das linhas curtas
                    lineColor: Colors.black, // Cor das linhas
                    selectedColor: Colors.blue, // Cor do valor selecionado
                    labelColor: Colors.grey, // Cor das labels
                    lineStroke: 2, // Largura das linhas
                    height: 150, // Altura total da régua
                  ),
                  
                  
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("CANCELAR"),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () async{

                          await firebaseService.salvarAltura(
                            altura: altura,
                          );
                          _buscarDados();
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // Salvar altura aqui, se necessário
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text("SALVAR", style: TextStyle(color: Colors.white),),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
