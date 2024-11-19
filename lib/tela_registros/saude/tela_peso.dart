import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/regua/simple_ruler_picker_peso.dart';

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

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    // Buscar último peso
    var ultimoPeso = await _firestoreService.buscarUltimoPeso();
    if (ultimoPeso != null) {
      setState(() {
        peso = '${ultimoPeso['peso']}';
        dataHora =
            '${ultimoPeso['data'].day}/${ultimoPeso['data'].month}/${ultimoPeso['data'].year} - ${ultimoPeso['hora']}';
        aux = double.parse(peso);
        aux *= 10;
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
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Card do último peso salvo
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.monitor_weight,
                          size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        '$peso Kg', // Exibe o último valor de peso salvo
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        dataHora, // Exibe a data e hora do último valor
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 34, 29, 29),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Exibir histórico de pesos em uma lista
            Expanded(
              child: ListView.builder(
                itemCount: historicoPesos.length,
                itemBuilder: (context, index) {
                  var registro = historicoPesos[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${registro['peso']} Kg',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${registro['hora']}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 34, 29, 29)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
