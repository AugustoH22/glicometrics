import 'package:flutter/material.dart';

class RefeicoesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> refeicoesDoDia;

  const RefeicoesWidget({
    super.key,
    required this.refeicoesDoDia,
  });

  @override
  Widget build(BuildContext context) {
    return refeicoesDoDia.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: refeicoesDoDia.length,
            itemBuilder: (context, index) {
              var refeicao = refeicoesDoDia[index];
              return ListTile(
                title: Text('Refeição: ${refeicao['nome']}'),
                subtitle: Text(
                    'Hora: ${refeicao['hora']} - Calorias: ${refeicao['calorias']} kcal'),
              );
            },
          )
        : const Text('Sem refeições registradas');
  }
}
