// ignore: file_names
import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';


class InformacaoScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  const InformacaoScreen({super.key, this.selectedDate, this.selectedTime});

  @override
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
    if (widget.selectedDate != null && widget.selectedTime != null) {
      await _firestoreService.salvarGlicemia(
        data: widget.selectedDate!,
        hora: widget.selectedTime!,
        tipo: glicemiaType!,
        valorGlicemia: glicemiaValue,
      );
      
      // Exibir mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados de glicemia salvos com sucesso!')),
      );

      // Voltar para a tela inicial
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
              Navigator.of(context).popUntil((route) => route.isFirst); // Voltar para a tela de registros
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      Navigator.pop(context); // Voltar para a tela de "Momento"
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    DropdownButton<String>(
                      value: glicemiaType,
                      hint: const Text('Selecione o tipo'),
                      isExpanded: true,
                      items: ['Jejum', 'Pós-prandial', 'Aleatória'].map((String value) {
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            const Spacer(),
            // Botão "Salvar"
            Center(
              child: ElevatedButton(
                onPressed: _isSaveButtonEnabled()
                    ? _saveGlicemiaData // Chama a função para salvar os dados no Firestore
                    : null,
                style: ElevatedButton.styleFrom(
                  disabledForegroundColor: Colors.grey.withOpacity(0.38),
                  disabledBackgroundColor: Colors.grey.withOpacity(0.12), // Cor do botão desabilitado
                ),
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
