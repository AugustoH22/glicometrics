import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/regua/simple_ruler_picker.dart';
import 'package:main/regua/simple_ruler_picker_peso.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:main/tela_home/widgets/grafico_peso.dart';

class PesoScreen extends StatefulWidget {
  const PesoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PesoScreenState createState() => _PesoScreenState();
}

class _PesoScreenState extends State<PesoScreen> {
  String peso = 'Carregando...';
  String dataHora = '';
  List<Map<String, dynamic>> historicoPesos = [];
  double aux = 0;
  double aux2 = 0;
  Map<String, double>? _pesoData;
  double pesoAtual = 0;
  double maiorPeso = 0;
  double menorPeso = 0;
   int altura = 170;
  double imc = 0;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    _pesoData = await _firestoreService.getPesoData();
    // Buscar último peso
    var ultimoPeso = await _firestoreService.buscarUltimoPeso();
    if (ultimoPeso != null) {
      setState(() {
        peso = '${ultimoPeso['peso']}';
        dataHora =
            '${ultimoPeso['data'].day}/${ultimoPeso['data'].month}/${ultimoPeso['data'].year} - ${ultimoPeso['hora']}';
        aux = double.parse(peso);
        aux *= 10;
        pesoAtual = _pesoData?['pesoAtual'] ?? 0;
        maiorPeso = _pesoData?['maiorPeso'] ?? 0;
        menorPeso = _pesoData?['menorPeso'] ?? 0;
        imc = (pesoAtual / ((altura / 100) * (altura / 100)));
      });
    } else {
      setState(() {
        peso = 'Sem dados';
        dataHora = '';
      });
      if (kDebugMode) {
        print(aux);
      }
    }

    // Buscar histórico de pesos
    var historico = await _firestoreService.buscarHistoricoPesos();
    setState(() {
      historicoPesos = historico;

      historicoPesos.sort((a, b) {
        DateTime dateA = _getDateTime(a['data'])!;
        DateTime dateB = _getDateTime(b['data'])!;
        return dateB.compareTo(dateA); // Decrescente
      });
    });
  }

  // Função auxiliar para converter diferentes formatos de data para DateTime
  DateTime? _getDateTime(dynamic data) {
    if (data == null) return null;
    if (data is DateTime) {
      return data;
    } else if (data is String) {
      return DateTime.tryParse(data);
    } else if (data is Timestamp) {
      return data.toDate(); // Conversão de Timestamp (Firebase)
    }
    return null; // Tipo desconhecido
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

// Função para formatar o dia em português
  String _formatDayInPortuguese(String date) {
    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    return capitalizeFirstLetter(
        DateFormat('EEEE, dd/MM/yyyy', 'pt_BR').format(parsedDate));
  }

  Map<String, Map<String, List<Map<String, dynamic>>>>
      _groupRefeicoesByMonthAndDay(List<Map<String, dynamic>> pesos) {
    Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};

    for (var historicoPesos in pesos) {
      DateTime? data = _getDateTime(historicoPesos['data']);
      if (data != null) {
        String month = capitalizeFirstLetter(
            DateFormat('MMMM yyyy', 'pt_BR').format(data)); // Nome do mês e ano
        String day =
            DateFormat('dd/MM/yyyy').format(data); // Dia no formato completo

        if (!grouped.containsKey(month)) {
          grouped[month] = {};
        }
        if (!grouped[month]!.containsKey(day)) {
          grouped[month]![day] = [];
        }
        grouped[month]![day]!.add(historicoPesos);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedRefeicoes =
        _groupRefeicoesByMonthAndDay(historicoPesos);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('Peso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Card do último peso salvo
              Center(
                child: GraficoPeso(pesoAtual: pesoAtual,
                      maiorPeso: maiorPeso,
                      menorPeso: menorPeso,
                      imc: imc,
                      altura: altura,
                      alterarAltura: _alterarAltura,),
              ),
              const SizedBox(height: 20),
              const Text(
                'Histórico',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Exibir histórico de pesos em uma lista
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupedRefeicoes.length,
                itemBuilder: (context, monthIndex) {
                  String month = groupedRefeicoes.keys.toList()[monthIndex];
                  Map<String, List<Map<String, dynamic>>> daysInMonth =
                      groupedRefeicoes[month]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          month,
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...daysInMonth.entries.map((dayEntry) {
                        String day = dayEntry.key;
                        List<Map<String, dynamic>> pesos = dayEntry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                _formatDayInPortuguese(
                                    day), // Formatar o dia com o nome do dia da semana
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ...pesos.map((historicoPesos) =>
                                _buildListItem(historicoPesos)),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _alterarPeso();
        },
        backgroundColor: const Color.fromARGB(255, 201, 199, 199),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> peso) {
    // Formatando a data para DD/MM
    DateTime? data = _getDateTime(peso['data']);
    String formattedDate = DateFormat('dd/MM').format(data!);

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.all(5),
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
        child: ListTile(
          title: Text(
            '${peso['peso']} Kg',
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            'Data: $formattedDate - ${peso['hora']}',
            style: const TextStyle(
                fontSize: 16, color: Color.fromARGB(255, 34, 29, 29)),
          ),
        ),
      ),
    );
  }

  void _alterarAltura() {
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
                    initialValue: altura, // Altura inicial
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
                        onPressed: () {
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

  // Função para alterar a altura e recalcular o IMC
  void _alterarPeso() {
    aux2 = double.parse(peso);
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
                    "Peso",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    " $aux2 Kg",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SimpleRulerPickerPeso(
                    minValue: 200, // Valor mínimo da altura
                    maxValue: 3000, // Valor máximo da altura
                    initialValue: aux.toInt(), // Altura inicial
                    onValueChanged: (value) {
                      setState(() {
                        // ignore: unused_local_variable
                        aux2 = value / 10;
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
                        onPressed: () async {
                          await _firestoreService.salvarPeso(
                            peso: aux2,
                          );
                          carregarDados();
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          "SALVAR",
                          style: TextStyle(color: Colors.white),
                        ),
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
