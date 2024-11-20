import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class AdicionarPressaoArterialScreen extends StatefulWidget {
  
  const AdicionarPressaoArterialScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdicionarPressaoArterialScreenState createState() =>
      _AdicionarPressaoArterialScreenState();
}

class _AdicionarPressaoArterialScreenState
    extends State<AdicionarPressaoArterialScreen> {
  final TextEditingController sistolicaController = TextEditingController();
  final TextEditingController diastolicaController = TextEditingController();
  

  DateTime? data = DateTime
      .now(); // Data da medição (pode ser gerada dinamicamente se necessário)
  TimeOfDay? hora = TimeOfDay
      .now(); // Hora da medição (pode ser gerada dinamicamente se necessário)

  final FirestoreService _firestoreService = FirestoreService();

  bool _isButtonEnabled = false;

  void _checkFields() {
    setState(() {
      // O botão é habilitado somente se os valores estiverem preenchidos
      _isButtonEnabled = sistolicaController.text.isNotEmpty &&
          diastolicaController.text.isNotEmpty;
    });
  }

  Future<void> _salvarPressaoArterial() async {
    DateTime dataComHora = data?.copyWith(
          hour: hora?.hour,
          minute: hora?.minute,
          second: 0, // Você pode ajustar para outros valores se necessário
          millisecond: 0,
          microsecond: 0,
        ) ??
        DateTime.now();
    if (_isButtonEnabled) {
      await _firestoreService.salvarPressaoArterial(
        sistolica: int.parse(sistolicaController.text),
        diastolica: int.parse(diastolicaController.text),
        data: dataComHora, // Usa a data atual
        hora: hora ??
            TimeOfDay.now(), // Usa a hora configurada (pode ser ajustada)
      );

      // Após salvar, redirecionar ou exibir uma mensagem
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    // Adiciona listeners para verificar o preenchimento dos campos
    sistolicaController.addListener(_checkFields);
    diastolicaController.addListener(_checkFields);
  }

  @override
  void dispose() {
    sistolicaController.dispose();
    diastolicaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Adicionar Pressão Arterial'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(
                    16.0), // Padding para o container principal
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey), // Contorno cinza claro
                  borderRadius:
                      BorderRadius.circular(8.0), // Bordas arredondadas
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Adicione sua Pressão Arterial',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Sistólica',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 50),
                        Text(
                          'Diastólica',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Campo para inserir Sistólica
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: sistolicaController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '/',
                          style: TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 10),
                        // Campo para inserir Diastólica
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: diastolicaController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
                              data != null
                                  ? DateFormat('dd/MM/yyyy').format(data!)
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
                              hora != null
                                  ? hora!.format(context)
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
              const SizedBox(height: 200),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _salvarPressaoArterial : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ), // Só habilita quando os campos são preenchidos
                child: const Text('Prosseguir'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função para selecionar a data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != data) {
      setState(() {
        data = picked;
      });
    }
  }

  // Função para selecionar a hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != hora) {
      setState(() {
        hora = picked;
      });
    }
  }
}
