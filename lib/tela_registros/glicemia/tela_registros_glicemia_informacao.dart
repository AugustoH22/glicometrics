// ignore: file_names
import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';

class InformacaoScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  const InformacaoScreen({super.key, this.selectedDate, this.selectedTime});

  @override
  // ignore: library_private_types_in_public_api
  _InformacaoScreenState createState() => _InformacaoScreenState();
}

class _InformacaoScreenState extends State<InformacaoScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  String? glicemiaType; // Para armazenar o tipo de glicemia selecionado
  String glicemiaValue = ""; // Para armazenar o valor de glicemia

  bool _isSaveButtonEnabled() {
    return glicemiaType != null && glicemiaValue.isNotEmpty;
  }

  Future<void> _saveGlicemiaData() async {
    DateTime dataComHora = widget.selectedDate?.copyWith(
          hour: widget.selectedTime?.hour,
          minute: widget.selectedTime?.minute,
          second: 0, // Você pode ajustar para outros valores se necessário
          millisecond: 0,
          microsecond: 0,
        ) ??
        DateTime.now();
    if (widget.selectedDate != null && widget.selectedTime != null) {
      await _firestoreService.salvarGlicemia(
        data: dataComHora,
        hora: widget.selectedTime!,
        tipo: glicemiaType!,
        valorGlicemia: glicemiaValue,
      );

      // Exibir mensagem de sucesso
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados de glicemia salvos com sucesso!')),
      );

      // Voltar para a tela inicial
      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      // Exibir mensagem de erro se a data ou hora não estiverem selecionadas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione a data e a hora da glicemia.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informação'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Voltar para a tela anterior
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).popUntil(
                  (route) => route.isFirst); // Voltar para a tela de registros
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Navegação
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                            context); // Voltar para a tela de "Momento"
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Momento >',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        // Já estamos na tela de "Informação", não faz nada
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'Informação >',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Seleção de tipo de glicemia
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Informe o tipo da glicemia',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      DropdownButton<String>(
                        value: glicemiaType,
                        hint: const Text('Selecione o tipo'),
                        isExpanded: true,
                        items: [
                          'Antes do Café da Manhã',
                          'Depois do Café da Manhã',
                          'Antes do Almoço',
                          'Depois do Almoço',
                          'Antes do Jantar',
                          'Depois do Jantar',
                          'Extra',
                          'Antes de Dormir / Madrugada',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            glicemiaType = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Campo para o valor da glicemia
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Informe o valor da glicemia',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Valor da glicemia',
                        ),
                        onChanged: (value) {
                          setState(() {
                            glicemiaValue = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Botão "Salvar"
              Center(
                child: ElevatedButton(
                  onPressed: _isSaveButtonEnabled()
                      ? _saveGlicemiaData // Chama a função para salvar os dados no Firestore
                      : null,
                  style: ElevatedButton.styleFrom(
                    disabledForegroundColor: Colors.grey.withOpacity(0.38),
                    disabledBackgroundColor: Colors.grey
                        .withOpacity(0.12), // Cor do botão desabilitado
                  ),
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
