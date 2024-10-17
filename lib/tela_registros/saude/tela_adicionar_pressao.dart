import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';


class AdicionarPressaoArterialScreen extends StatefulWidget {
  const AdicionarPressaoArterialScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdicionarPressaoArterialScreenState createState() => _AdicionarPressaoArterialScreenState();
}

class _AdicionarPressaoArterialScreenState extends State<AdicionarPressaoArterialScreen> {
  final TextEditingController sistolicaController = TextEditingController();
  final TextEditingController diastolicaController = TextEditingController();

  String data = "12/06/2024"; // Data da medição (pode ser gerada dinamicamente se necessário)
  String hora = "18:30"; // Hora da medição (pode ser gerada dinamicamente se necessário)

   final FirestoreService _firestoreService = FirestoreService();

  bool _isButtonEnabled = false;

  void _checkFields() {
    setState(() {
      // O botão é habilitado somente se os valores estiverem preenchidos
      _isButtonEnabled = sistolicaController.text.isNotEmpty && diastolicaController.text.isNotEmpty;
    });
  }

  Future<void> _salvarPressaoArterial() async {
    if (_isButtonEnabled) {
      await _firestoreService.salvarPressaoArterial(
        sistolica: int.parse(sistolicaController.text),
        diastolica: int.parse(diastolicaController.text),
        data: DateTime.now(), // Usa a data atual
        hora: hora, // Usa a hora configurada (pode ser ajustada)
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Adicione sua Pressão Arterial',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              '*Em mmHg',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Sistólica (mmHg)',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 50),
                Text(
                  'Diastólica (mmHg)',
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '000',
                    ),
                    maxLength: 3,
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '000',
                    ),
                    maxLength: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Data e Hora da Medição:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data, // Exibe a data
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 20),
                Text(
                  hora, // Exibe a hora
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isButtonEnabled ? _salvarPressaoArterial : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ), // Só habilita quando os campos são preenchidos
              child: const Text('Prosseguir'),
            ),
          ],
        ),
      ),
    );
  }
}
