import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/tela_registros/saude/tela_peso.dart';
// Importar o arquivo de serviço

class AdicionarPesoScreen extends StatefulWidget {
  const AdicionarPesoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdicionarPesoScreenState createState() => _AdicionarPesoScreenState();
}

class _AdicionarPesoScreenState extends State<AdicionarPesoScreen> {
  final TextEditingController pesoController = TextEditingController();

  DateTime data = DateTime.now();
  TimeOfDay hora = TimeOfDay.now();

  final FirestoreService _firestoreService =
      FirestoreService(); // Instância do serviço Firebase

  bool _isButtonEnabled = false;

  void _checkFields() {
    setState(() {
      // O botão é habilitado somente se o valor do peso estiver preenchido
      _isButtonEnabled = pesoController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    // Adiciona listener para verificar o preenchimento do campo de peso
    pesoController.addListener(_checkFields);
  }

  @override
  void dispose() {
    pesoController.dispose();
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
        title: const Text('Adicionar Peso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Adicione seu Peso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              '*Em KG',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Campo para inserir o peso
            SizedBox(
              width: 150,
              child: TextField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '000',
                ),
                maxLength: 5,
              ),
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
                  '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}', // Exibe a data
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 20),
                Text(
                  '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}', // Exibe a hora
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isButtonEnabled
                  ? () async {
                      await _firestoreService.salvarPeso(
                        peso: double.parse(pesoController.text),
                      );
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PesoScreen()),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ), // Só habilita quando o campo de peso é preenchido
              child: const Text('Prosseguir'),
            ),
          ],
        ),
      ),
    );
  }
}
