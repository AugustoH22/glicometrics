import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/tela_registros/saude/tela_adicionar_peso.dart';


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
        peso = '${ultimoPeso['peso']} kg';
        dataHora = '${ultimoPeso['data'].toDate().day}/${ultimoPeso['data'].toDate().month}/${ultimoPeso['data'].toDate().year} - ${ultimoPeso['hora']}';
      });
    } else {
      setState(() {
        peso = 'Sem dados';
        dataHora = '';
      });
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
      appBar: AppBar(
        title: const Text('Peso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.monitor_weight, size: 40, color: Colors.blue),
                      const SizedBox(height: 10),
                      Text(
                        peso, // Exibe o último valor de peso salvo
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
                          color: Colors.grey,
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
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${registro['peso']} kg',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${registro['hora']}',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdicionarPesoScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

