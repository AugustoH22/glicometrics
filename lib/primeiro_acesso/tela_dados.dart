import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:main/firebase/firestore_service.dart';
import 'tela_dados_medicos.dart';

class TelaDadosPessoais extends StatefulWidget {
  const TelaDadosPessoais({super.key});

  @override
  State<TelaDadosPessoais> createState() => _TelaDadosPessoaisState();
}

class _TelaDadosPessoaisState extends State<TelaDadosPessoais> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController nascimentoController = TextEditingController();
  final FocusNode nomeFocusNode = FocusNode();
  final FocusNode sobrenomeFocusNode = FocusNode();
  final FocusNode celularFocusNode = FocusNode();
  final FocusNode nascimentoFocusNode = FocusNode();
  String genero = "------";

  bool isValid = false;
  final FirestoreService _firestoreService = FirestoreService();

  void _validate() {
    setState(() {
      isValid = nomeController.text.isNotEmpty &&
          sobrenomeController.text.isNotEmpty &&
          celularController.text.isNotEmpty &&
          nascimentoController.text.isNotEmpty &&
          genero != "------";
    });
  }

  @override
  void initState() {
    super.initState();
    _buscarDados();
    nomeController.addListener(_validate);
    sobrenomeController.addListener(_validate);
    celularController.addListener(_validate);
    nascimentoController.addListener(_validate);
    nomeFocusNode.addListener(_onFocusChange);
    sobrenomeFocusNode.addListener(_onFocusChange);
    celularFocusNode.addListener(_onFocusChange);
    nascimentoFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    nomeFocusNode.removeListener(_onFocusChange);
    sobrenomeFocusNode.removeListener(_onFocusChange);
    celularFocusNode.removeListener(_onFocusChange);
    nascimentoFocusNode.removeListener(_onFocusChange);
    nomeFocusNode.dispose();
    sobrenomeFocusNode.dispose();
    celularFocusNode.dispose();
    nascimentoFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!nomeFocusNode.hasFocus ||
        !sobrenomeFocusNode.hasFocus ||
        !celularFocusNode.hasFocus ||
        !nascimentoFocusNode.hasFocus) {
      _validate();
    }
  }

  Future<void> _buscarDados() async {

    var dadosPessoais = await _firestoreService.getDadosPessoais();


    setState(() {
      nomeController.text = dadosPessoais?['nome'] ?? 'Nome';
      sobrenomeController.text = dadosPessoais?['sobrenome'] ?? 'Sobrenome';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dados Pessoais"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dados Pessoais",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(label: "Nome*", controller: nomeController),
            const SizedBox(height: 16),
            _buildTextField(
                label: "Sobrenome*", controller: sobrenomeController),
            const SizedBox(height: 16),
            _buildMaskedTextField(
              label: "Celular*",
              controller: celularController,
              mask: MaskedInputFormatter('(00) 00000-0000'),
            ),
            const SizedBox(height: 16),
            _buildMaskedTextField(
              label: "Data de Nascimento*",
              controller: nascimentoController,
              mask: MaskedInputFormatter('00/00/0000'),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: "Gênero*",
              value: genero,
              items: ["------", "Feminino", "Masculino", "Outro"],
              onChanged: (value) {
                _validate();
                setState(() {
                  genero = value ?? " ";
                  _validate();
                });
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TelaDadosMedicos(
                              nome: nomeController.text,
                              sobrenome: sobrenomeController.text,
                              celular: celularController.text,
                              nascimento: nascimentoController.text,
                              genero: genero,
                            ),
                          ),
                        );
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Preencha todos os campos!"),
                            duration:
                                Duration(seconds: 2), // Duração da exibição
                          ),
                        );
                      },
                child: const Text("Continuar"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: (_) {},
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaskedTextField({
    required String label,
    required TextEditingController controller,
    required MaskedInputFormatter mask,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: (_) {},
          inputFormatters: [mask],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (selectedValue) {
            setState(() {
              onChanged(selectedValue);
              _validate();
            });
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
