import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredRefeicoes = _filterRefeicoes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterOptions(),
        filteredRefeicoes.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredRefeicoes.length,
                itemBuilder: (context, index) {
                  return _buildListItem(filteredRefeicoes[index]);
                },
              )
            : const Center(
                child: Text(
                  'Sem refeições registradas no período selecionado.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
      ],
    );
  }

  // Função para renderizar um item
  // Função para renderizar um item
  Widget _buildListItem(Map<String, dynamic> refeicao) {
    // Formatando a data para DD/MM
    String formattedDate = '';
    DateTime? data = _getDateTime(refeicao['selectedDate']);
    formattedDate = DateFormat('dd/MM').format(data!);

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

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey), // Borda cinza clara
        ),
      ),
      child: ListTile(
        leading: Icon(mealIcon, color: Colors.blue), // Ícone baseado no tipo
        title: Text('Refeição: ${refeicao['selectedMeal']}'),
        subtitle: Text(
            'Data: $formattedDate - ${refeicao['selectedTime']} - Calorias: ${refeicao['totalCalorias']} kcal'),
      ),
    );
  }

  // Opções de filtro
  Widget _buildFilterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
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
      ],
    );
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

  // Filtra as refeições com base no filtro selecionado
  List<Map<String, dynamic>> _filterRefeicoes() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> refeicoes = widget.refeicoesDoDia;

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
}
