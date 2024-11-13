import 'package:flutter/material.dart';

class HistoricoRegistros extends StatelessWidget {
  final List<Map<String, dynamic>> historicoRegistros;

  const HistoricoRegistros({
    super.key,
    required this.historicoRegistros,
  });

  @override
  Widget build(BuildContext context) {
    return historicoRegistros.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historicoRegistros.length,
            itemBuilder: (context, index) {
              var registro = historicoRegistros[index];
              return ListTile(
                title: Text('${registro['tipo']} - ${registro['hora']}'),
                subtitle: Text('Data: ${registro['data'].toString().substring(0, 10)}'),
                trailing: Text(
                  registro['tipo'] == 'Pressão Arterial'
                      ? '${registro['sistolica']}/${registro['diastolica']} mmHg'
                      : registro['tipo'] == 'Peso'
                          ? '${registro['peso']} kg'
                          : '${registro['valor']} mg/dL',
                ),
              );
            },
          )
        : const Text('Sem registros disponíveis.');
  }
}
