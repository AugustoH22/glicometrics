import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class RefeicoesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> refeicoesDoDia;

  const RefeicoesWidget({
    super.key,
    required this.refeicoesDoDia,
  });

  @override
  State<RefeicoesWidget> createState() => _RefeicoesWidgetState();
}

class _RefeicoesWidgetState extends State<RefeicoesWidget> {
  DateTimeRange? _selectedDateRange;
  String _selectedFilter = 'Hoje'; // Filtro inicial
  String _selectedMealType = 'Todas'; // Filtro para o tipo de refeição

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredRefeicoes = _filterRefeicoes();

    // Ordenar registros pela data (mais recente para a mais antiga)
    filteredRefeicoes.sort((a, b) {
      DateTime dateA = _getDateTime(a['selectedDate'])!;
      DateTime dateB = _getDateTime(b['selectedDate'])!;
      return dateB.compareTo(dateA); // Decrescente
    });

    // Agrupar registros por mês e dia
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedRefeicoes =
        _groupRefeicoesByMonthAndDay(filteredRefeicoes);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterOptions(),
          const SizedBox(height: 16),
          filteredRefeicoes.isNotEmpty
              ? ListView.builder(
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
                          List<Map<String, dynamic>> refeicoes = dayEntry.value;

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
                              ...refeicoes
                                  .map((refeicao) => _buildListItem(refeicao))
                                  ,
                            ],
                          );
                        }),
                      ],
                    );
                  },
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Sem refeições registradas no período selecionado.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Função para renderizar um item
  Widget _buildListItem(Map<String, dynamic> refeicao) {
    // Formatando a data para DD/MM
    DateTime? data = _getDateTime(refeicao['selectedDate']);
    String formattedDate = DateFormat('dd/MM').format(data!);

    // Definindo o ícone baseado no tipo de refeição
    IconData mealIcon = Icons.fastfood; // Padrão
    switch (refeicao['selectedMeal']?.toLowerCase()) {
      case 'almoço':
        mealIcon = Icons.lunch_dining;
        break;
      case 'janta':
        mealIcon = Icons.dinner_dining;
        break;
      case 'lanche':
        mealIcon = Icons.fastfood;
        break;
      case 'café':
        mealIcon = Icons.coffee;
        break;
    }

    return GestureDetector(
      onTap: () => _showRefeicaoDetails(refeicao),
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
          leading: Icon(mealIcon, color: Colors.grey), // Ícone baseado no tipo
          title: Text('Refeição: ${refeicao['selectedMeal']}'),
          subtitle: Text(
              'Data: $formattedDate - ${refeicao['selectedTime']} - Calorias: ${refeicao['totalCalorias']} kcal'),
        ),
      ),
    );
  }

  // Opções de filtro
  Widget _buildFilterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.filter_alt, color: Colors.grey),
        Text(
          "Filtro: ",
          style: TextStyle(fontSize: 18),
        ),
        DropdownButton<String>(
          value: _selectedFilter,
          items: [
            'Hoje',
            'Últimos 7 dias',
            'Último mês',
            'Personalizado',
          ].map((filter) {
            return DropdownMenuItem(
              value: filter,
              child: Text(filter),
            );
          }).toList(),
          onChanged: (value) async {
            if (value == 'Personalizado') {
              await _selectCustomDateRange();
            } else {
              setState(() {
                _selectedFilter = value!;
                _selectedDateRange = null; // Reseta a seleção personalizada
              });
            }
          },
        ),
        DropdownButton<String>(
          value: _selectedMealType,
          items: [
            'Todas',
            'Almoço',
            'Janta',
            'Lanche',
            'Café',
          ].map((meal) {
            return DropdownMenuItem(
              value: meal,
              child: Text(meal),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMealType = value!;
            });
          },
        ),
      ],
    );
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

  // Função para agrupar refeições por mês e dia
  Map<String, Map<String, List<Map<String, dynamic>>>>
      _groupRefeicoesByMonthAndDay(List<Map<String, dynamic>> refeicoes) {
    Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};

    for (var refeicao in refeicoes) {
      DateTime? data = _getDateTime(refeicao['selectedDate']);
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
        grouped[month]![day]!.add(refeicao);
      }
    }

    return grouped;
  }

  void _showRefeicaoDetails(Map<String, dynamic> refeicao) {
    // Detalhes do card
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Cor de fundo do card
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 600, // Limite máximo de altura do card
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhes da Refeição',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                          'Tipo', refeicao['selectedMeal'] ?? 'N/A'),
                      _buildDetailRow(
                          'Calorias', '${refeicao['totalCalorias'] ?? 0} kcal'),
                      const SizedBox(height: 16),
                      Text(
                        'Itens Consumidos',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      ..._buildFoodList(refeicao['items']),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context), // Fechar o modal
                          child: const Text('Fechar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Função para criar a lista de alimentos
  List<Widget> _buildFoodList(List<dynamic>? items) {
    if (items == null || items.isEmpty) {
      return [
        const Text(
          'Nenhum alimento registrado.',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        )
      ];
    }

    return items.map<Widget>((item) {
      // Verificar se o item e seu campo 'food' são válidos
      if (item is! Map<String, dynamic> ||
          item['food'] is! Map<String, dynamic>) {
        return const Text(
          'Dados inválidos.',
          style: TextStyle(color: Colors.red, fontSize: 14),
        );
      }

      Map<String, dynamic> food = item['food'];
      String nome = food['nome'] ?? 'N/A';
      String porcao = item['porcao'] ?? 'N/A';
      String quantidade = item['quantity']?.toString() ?? 'N/A';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('Porção: $porcao'),
            Text('Quantidade: $quantidade'),
          ],
        ),
      );
    }).toList();
  }

// Função para criar uma linha de detalhe no card
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // Filtra as refeições com base no filtro selecionado
  List<Map<String, dynamic>> _filterRefeicoes() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> refeicoes = widget.refeicoesDoDia;

    refeicoes = refeicoes.where((refeicao) {
      if (_selectedMealType != 'Todas' &&
          refeicao['selectedMeal']?.toLowerCase() !=
              _selectedMealType.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    if (_selectedFilter == 'Hoje') {
      return refeicoes.where((refeicao) {
        DateTime? dataRefeicao = _getDateTime(refeicao['selectedDate']);
        if (dataRefeicao == null) return false;
        return isSameDay(dataRefeicao, now);
      }).toList();
    } else if (_selectedFilter == 'Últimos 7 dias') {
      DateTime weekAgo = now.subtract(const Duration(days: 7));
      return refeicoes.where((refeicao) {
        DateTime? dataRefeicao = _getDateTime(refeicao['selectedDate']);
        if (dataRefeicao == null) return false;
        return dataRefeicao.isAfter(weekAgo) ||
            isSameDay(dataRefeicao, weekAgo);
      }).toList();
    } else if (_selectedFilter == 'Último mês') {
      DateTime monthAgo = DateTime(now.year, now.month - 1, now.day);
      return refeicoes.where((refeicao) {
        DateTime? dataRefeicao = _getDateTime(refeicao['selectedDate']);
        if (dataRefeicao == null) return false;
        return dataRefeicao.isAfter(monthAgo) ||
            isSameDay(dataRefeicao, monthAgo);
      }).toList();
    } else if (_selectedFilter == 'Personalizado' &&
        _selectedDateRange != null) {
      DateTime start = _selectedDateRange!.start;
      DateTime end = _selectedDateRange!.end;
      return refeicoes.where((refeicao) {
        DateTime? dataRefeicao = _getDateTime(refeicao['selectedDate']);
        if (dataRefeicao == null) return false;
        return dataRefeicao.isAfter(start.subtract(const Duration(days: 1))) &&
            dataRefeicao.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    }

    return refeicoes; // Sem filtro ou filtro inválido
  }

  // Função auxiliar para verificar se duas datas são no mesmo dia
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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

  // Função para abrir um seletor de intervalo de datas
  Future<void> _selectCustomDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _selectedFilter = 'Personalizado';
      });
    }
  }
}
