import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/tela_registros/saude/tela_adicionar_pressao.dart';

class PressaoArterialScreen extends StatefulWidget {
  const PressaoArterialScreen({super.key});

  @override
  _PressaoArterialScreenState createState() => _PressaoArterialScreenState();
}

class _PressaoArterialScreenState extends State<PressaoArterialScreen> {
  Map<String, dynamic>? _dadosPressao;
  List<Map<String, dynamic>> _historicoPressao = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buscarDadosPressao();
  }

  // Função para buscar os dados do Firebase
  Future<void> _buscarDadosPressao() async {
    final FirestoreService firestoreService = FirestoreService();
    Map<String, dynamic>? dados =
        await firestoreService.getUltimoRegistroPressao();
    List<Map<String, dynamic>> historico =
        await firestoreService.getHistoricoPressao();

    setState(() {
      _dadosPressao = dados;
      _historicoPressao = historico;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Voltar para a tela anterior
          },
        ),
        centerTitle: true,
        title: const Text(
          'Pressão Arterial',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dadosPressao == null
              ? const Center(child: Text('Sem medições disponíveis.'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Container fixo na parte superior
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'SYS/mmHg       DIA/mmHg',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_dadosPressao!['sistolica']}       ${_dadosPressao!['diastolica']}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Hora: ${_dadosPressao!['hora']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Lista de histórico de medições
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Histórico de medições',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _historicoPressao.length,
                        itemBuilder: (context, index) {
                          final registro = _historicoPressao[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(
                                  'Sistólica: ${registro['sistolica']} - Diastólica: ${registro['diastolica']}'),
                              subtitle: Text(
                                  'Hora: ${registro['hora']} - Data: ${DateTime.fromMillisecondsSinceEpoch(registro['data'].seconds * 1000)}'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
                builder: (context) => const AdicionarPressaoArterialScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
