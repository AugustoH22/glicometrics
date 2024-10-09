import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_informacao.dart';

class RefeicaoScreen extends StatefulWidget {
  final DateTime? selectedDate; // Para manter o valor selecionado ao voltar
  final TimeOfDay? selectedTime;
  final String? selectedOption;

  const RefeicaoScreen({super.key, this.selectedDate, this.selectedTime, this.selectedOption});

  @override
  // ignore: library_private_types_in_public_api
  _RefeicaoScreenState createState() => _RefeicaoScreenState();
}

class _RefeicaoScreenState extends State<RefeicaoScreen> {
  String? selectedOption = ""; // Variável para armazenar a opção selecionada
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Variáveis para controlar se as telas foram visitadas
  bool infoScreenVisited = false;
  bool refeicaoScreenVisited = false;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.selectedOption;
    selectedDate = widget.selectedDate;
    selectedTime = widget.selectedTime;
  }

  // Função para selecionar a data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Função para selecionar a hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  bool _isNextButtonEnabled() {
    if (selectedOption == "AGORA") {
      return true;
    } else if (selectedOption == "Passado" &&
        selectedDate != null &&
        selectedTime != null) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refeição'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).popUntil(
                (route) => route.isFirst); // Voltar para a tela anterior
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tela "Momento", sempre disponível
                  GestureDetector(
                    onTap: () {
                      // Já estamos na tela de "Momento", não faz nada
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Momento >',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Tela "Informação", só habilitada se o botão "Próximo" foi clicado ao menos uma vez
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.info,
                            color:
                                infoScreenVisited ? Colors.blue : Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Informação >',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                infoScreenVisited ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Tela "Refeição", só habilitada se a tela anterior foi visitada
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.restaurant,
                            color: refeicaoScreenVisited
                                ? Colors.blue
                                : Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Refeição >',
                          style: TextStyle(
                            fontSize: 16,
                            color: refeicaoScreenVisited
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Conteúdo de seleção de momento e outras funcionalidades
            _buildMomentSelection(),
            const SizedBox(height: 20),
            // Exibe o container adicional apenas se "Passado" for selecionado
            if (selectedOption == "Passado")
              Center(
                child: Container(
                  padding: const EdgeInsets.all(
                      16.0), // Padding para o container principal
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.grey), // Contorno cinza claro
                    borderRadius:
                        BorderRadius.circular(8.0), // Bordas arredondadas
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Centraliza o conteúdo
                    children: [
                      const Text(
                        'Quando ocorreu essa glicemia?',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Campo para selecionar a data
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey), // Contorno cinza claro
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              selectedDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(selectedDate!)
                                  : 'Selecione a data',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Campo para selecionar a hora
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey), // Contorno cinza claro
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              selectedTime != null
                                  ? selectedTime!.format(context)
                                  : 'Selecione a hora',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            // Botão "Próximo" para habilitar a navegação
            Center(
              child: ElevatedButton(
                onPressed: _isNextButtonEnabled()
                    ? () {
                        setState(() {
                          // Quando o botão for clicado, habilitar a próxima tela
                          infoScreenVisited = true;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InformacaoRefeicaoScreen(
                              selectedOption: selectedOption,
                              selectedDate: selectedDate,
                              selectedTime: selectedTime,
                            ),
                          ),
                        ).then((result) {
                          if (result != null) {
                            setState(() {
                              // Atualiza os dados com os valores retornados
                              selectedOption = result['selectedOption'];
                              selectedDate = result['selectedDate'];
                              selectedTime = result['selectedTime'];
                            });
                          }
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  disabledForegroundColor: Colors.grey.withOpacity(0.38),
                  disabledBackgroundColor: Colors.grey
                      .withOpacity(0.12), // Cor do botão quando desabilitado
                ),
                child: const Text('Próximo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função que constrói o widget de seleção de momento
  Widget _buildMomentSelection() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Contorno cinza claro
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Momento da Refeição',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = "AGORA";
                      selectedDate = null;
                      selectedTime = null;
                    });
                  },
                  child: Container(
                    width: 90, // Define a largura do quadrado
                    height: 90,
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: selectedOption == "AGORA"
                              ? Colors.blue
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.access_time,
                            color: selectedOption == "AGORA"
                                ? Colors.blue
                                : Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'AGORA',
                          style: TextStyle(
                            color: selectedOption == "AGORA"
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = "Passado";
                    });
                  },
                  child: Container(
                    width: 90, // Define a largura do quadrado
                    height: 90,
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: selectedOption == "Passado"
                              ? Colors.blue
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.history,
                            color: selectedOption == "Passado"
                                ? Colors.blue
                                : Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'Passado',
                          style: TextStyle(
                            color: selectedOption == "Passado"
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
