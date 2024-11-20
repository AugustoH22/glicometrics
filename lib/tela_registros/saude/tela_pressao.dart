import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/tela_home/widgets/grafico_pressao.dart';
import 'package:main/tela_registros/saude/tela_adicionar_pressao.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class PressaoArterialScreen extends StatefulWidget {
  const PressaoArterialScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PressaoArterialScreenState createState() => _PressaoArterialScreenState();
}

class _PressaoArterialScreenState extends State<PressaoArterialScreen> {
  Map<String, dynamic>? _dadosPressao;
  List<Map<String, dynamic>> _historicoPressao = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _ultimasPressao = [];
  Map<String, dynamic>? _ultimaPressao;

  @override
  void initState() {
    super.initState();
    _buscarDadosPressao();
  }

  // Função para buscar os dados do Firebase
  Future<void> _buscarDadosPressao() async {
    final FirestoreService firestoreService = FirestoreService();
    _ultimaPressao = await firestoreService.getUltimoRegistroPressao();
    _ultimasPressao = await firestoreService.getUltimasMedicoesPressao();
    Map<String, dynamic>? dados =
        await firestoreService.getUltimoRegistroPressao();
    List<Map<String, dynamic>> historico =
        await firestoreService.getHistoricoPressao();

    setState(() {
      _dadosPressao = dados;
      _historicoPressao = historico;
      _isLoading = false;
      _historicoPressao.sort((a, b) {
        DateTime dateA = _getDateTime(a['data'])!;
        DateTime dateB = _getDateTime(b['data'])!;
        return dateB.compareTo(dateA); // Decrescente
      });
    });
  }

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
      _groupRefeicoesByMonthAndDay(List<Map<String, dynamic>> pressao) {
    Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};

    // ignore: no_leading_underscores_for_local_identifiers
    for (var _historicoPressao in pressao) {
      DateTime? data = _getDateTime(_historicoPressao['data']);
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
        grouped[month]![day]!.add(_historicoPressao);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedRefeicoes =
        _groupRefeicoesByMonthAndDay(_historicoPressao);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).popUntil(
                (route) => route.isFirst); // Voltar para a tela anterior
          },
        ),
        title: const Text(
          'Pressão Arterial',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dadosPressao == null
              ? const Center(child: Text('Sem medições disponíveis.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Card do último peso salvo
                        Center(
                          child: GraficoPressao(
                            ultimaPressao: _ultimaPressao,
                            ultimasPressao: _ultimasPressao,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Histórico',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        // Exibir histórico de pesos em uma lista
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groupedRefeicoes.length,
                          itemBuilder: (context, monthIndex) {
                            String month =
                                groupedRefeicoes.keys.toList()[monthIndex];
                            Map<String, List<Map<String, dynamic>>>
                                daysInMonth = groupedRefeicoes[month]!;

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
                                  List<Map<String, dynamic>> pesos =
                                      dayEntry.value;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
                builder: (context) => const AdicionarPressaoArterialScreen()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 201, 199, 199),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> pressao) {
    // Formatando a data para DD/MM
    DateTime? data = _getDateTime(pressao['data']);
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
            'Sistólica: ${pressao['sistolica']} - Diastólica: ${pressao['diastolica']}',
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            'Data: $formattedDate - ${pressao['hora']}',
            style: const TextStyle(
                fontSize: 16, color: Color.fromARGB(255, 34, 29, 29)),
          ),
        ),
      ),
    );
  }
}
