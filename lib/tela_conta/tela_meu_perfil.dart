// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/regua/simple_ruler_picker.dart';
import 'package:main/regua/simple_ruler_picker_peso.dart';

class DadosPessoaisPage extends StatefulWidget {
  const DadosPessoaisPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DadosPessoaisPageState createState() => _DadosPessoaisPageState();
}

class _DadosPessoaisPageState extends State<DadosPessoaisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  // Controladores dos campos de texto
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController nascimentoController = TextEditingController();
  final TextEditingController diagnosticoController = TextEditingController();

  // Valores dos dropdowns
  String tipoDiabetes = "Diabetes Tipo 1";
  String terapia = "Não uso Insulina";
  String usaMedicamentos = "Não";
  String genero = "Masculino";
  

  // Estado do botão Salvar
  bool isDadosPessoaisValid = false;
  bool isDadosMedicosValid = false;

  Map<String, dynamic>? dadosPessoais = {};

  int altura = 170;
  double peso = 0;
  double aux2 = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    //_buscarDados();

    // Adiciona listeners para verificar o estado dos campos
    nomeController.addListener(_validateDadosPessoais);
    sobrenomeController.addListener(_validateDadosPessoais);
    celularController.addListener(_validateDadosPessoais);
    nascimentoController.addListener(_validateDadosPessoais);
    diagnosticoController.addListener(_validateDadosMedicos);
  }

  Future<void> _buscarDados() async {

    dadosPessoais = await _firestoreService.getDadosPessoais();

    var ultimoPeso = await _firestoreService.buscarUltimoPeso();
    if (ultimoPeso != null) {
      setState(() {
        peso = ultimoPeso['peso'];
        peso *= 10;
      });
    } 
    

    setState(() {
      nomeController.text = dadosPessoais?['nome'] ?? '';
      sobrenomeController.text = dadosPessoais?['sobrenome'] ?? '';
      celularController.text = dadosPessoais?['celular'] ?? '';
      nascimentoController.text = dadosPessoais?['dataNascimento'] ?? '';
      genero = dadosPessoais?['genero'] ?? '';
    });
  }

  Future<void> _saveDadosPessoais() async {
    await _firestoreService.salvarDadosPessoais(
      nome: nomeController.text,
      sobrenome: sobrenomeController.text,
      celular: celularController.text,
      dataNascimento: nascimentoController.text,
      genero: genero,
    );

    // Exibir mensagem de sucesso
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados salvos com sucesso!')),
    );

    // Voltar para a tela inicial
    // ignore: use_build_context_synchronously
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _validateDadosPessoais() {
    setState(() {
      isDadosPessoaisValid = nomeController.text.isNotEmpty &&
          sobrenomeController.text.isNotEmpty &&
          celularController.text.isNotEmpty &&
          nascimentoController.text.isNotEmpty &&
          genero != null;
    });
  }

  void _validateDadosMedicos() {
    setState(() {
      isDadosMedicosValid = tipoDiabetes != null &&
          terapia != null &&
          usaMedicamentos != null &&
          diagnosticoController.text.isNotEmpty &&
          peso!= null ;
    });
  }

  @override
  void dispose() {
    // Dispose dos controladores
    nomeController.dispose();
    sobrenomeController.dispose();
    celularController.dispose();
    nascimentoController.dispose();
    diagnosticoController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Dados"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Dados Pessoais"),
            Tab(text: "Dados Médicos"),
          ],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _dadosPessoaisTab(),
          _dadosMedicosTab(),
        ],
      ),
    );
  }

  Widget _dadosPessoaisTab() {
    return SingleChildScrollView(
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
          _buildTextField(label: "Sobrenome*", controller: sobrenomeController),
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
            items: ["Feminino", "Masculino", "Outro"],
            onChanged: (value) {
              setState(() {
                genero = value ?? " ";
                _validateDadosPessoais();
              });
            },
          ),
          const SizedBox(height: 32),
          _buildSalvarButton(
            isEnabled: isDadosPessoaisValid,
            onPressed: () {
              if (isDadosPessoaisValid) {
                _saveDadosPessoais();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados Pessoais Salvos!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _dadosMedicosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dados Médicos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 50),
              Column(
                children: [
                  const Text(
                    "Peso*",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _alterarPeso();
                      });
                    },
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black.withAlpha(140)), // Contorno cinza claro
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          " Kg",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 50),
              Column(
                children: [
                  const Text(
                    "Altura*",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _alterarAltura();
                      });
                    },
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black.withAlpha(140)), // Contorno cinza claro
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          " Kg",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: "Tipo de Diabetes*",
            value: tipoDiabetes,
            items: [
              "Diabetes Tipo 1",
              "Diabetes Tipo 2",
              "Gestacional",
              "Lada",
              "Mody",
              "Pré-Diabetes",
              "Outro"
            ],
            onChanged: (value) {
              setState(() {
                tipoDiabetes = value ?? " ";
                _validateDadosMedicos();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: "Terapia*",
            value: terapia,
            items: [
              "Caneta",
              "Seringa",
              "Bomba de Insulina",
              "Não uso Insulina",
              "Outro"
            ],
            onChanged: (value) {
              setState(() {
                terapia = value ?? " ";
                _validateDadosMedicos();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: "Usa Medicamentos*",
            value: usaMedicamentos,
            items: ["Sim", "Não"],
            onChanged: (value) {
              setState(() {
                usaMedicamentos = value ?? " ";
                _validateDadosMedicos();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildMaskedTextField(
            label: "Data do Diagnóstico*",
            controller: diagnosticoController,
            mask: MaskedInputFormatter('00/00/0000'),
          ),
          const SizedBox(height: 32),
          _buildSalvarButton(
            isEnabled: isDadosMedicosValid,
            onPressed: () {
              if (isDadosMedicosValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados Médicos Salvos!')),
                );
              }
            },
          ),
        ],
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
          onChanged: (_) {
            _validateDadosPessoais();
            _validateDadosMedicos();
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
          onChanged: (_) {
            _validateDadosPessoais();
            _validateDadosMedicos();
          },
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
          onChanged: onChanged,
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

  Widget _buildSalvarButton({
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.blue[800] : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isEnabled ? onPressed : null,
        child: const Text(
          "Salvar",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  void _alterarAltura() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Altura",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "${altura.toStringAsFixed(0)} cm",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SimpleRulerPicker(
                    minValue: 120, // Valor mínimo da altura
                    maxValue: 220, // Valor máximo da altura
                    initialValue: altura, // Altura inicial
                    onValueChanged: (value) {
                      setState(() {
                        altura = value;
                      });
                    },
                    scaleLabelSize: 16, // Tamanho da fonte das labels
                    scaleBottomPadding: 8, // Padding inferior das labels
                    scaleItemWidth: 12, // Largura de cada item de escala
                    longLineHeight: 70, // Altura das linhas longas
                    shortLineHeight: 35, // Altura das linhas curtas
                    lineColor: Colors.black, // Cor das linhas
                    selectedColor: Colors.blue, // Cor do valor selecionado
                    labelColor: Colors.grey, // Cor das labels
                    lineStroke: 2, // Largura das linhas
                    height: 150, // Altura total da régua
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("CANCELAR"),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Salvar altura aqui, se necessário
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          "SALVAR",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Função para alterar a altura e recalcular o IMC
  void _alterarPeso() {
    aux2 = peso;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Peso",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "$aux2 Kg",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SimpleRulerPickerPeso(
                    minValue: 200, // Valor mínimo da altura
                    maxValue: 3000, // Valor máximo da altura
                    initialValue: peso.toInt(), // Altura inicial
                    onValueChanged: (value) {
                      setState(() {

                        aux2 = value / 10;

                      });
                    },
                    scaleLabelSize: 16, // Tamanho da fonte das labels
                    scaleBottomPadding: 8, // Padding inferior das labels
                    scaleItemWidth: 12, // Largura de cada item de escala
                    longLineHeight: 70, // Altura das linhas longas
                    shortLineHeight: 35, // Altura das linhas curtas
                    lineColor: Colors.black, // Cor das linhas
                    selectedColor: Colors.blue, // Cor do valor selecionado
                    labelColor: Colors.grey, // Cor das labels
                    lineStroke: 2, // Largura das linhas
                    height: 150, // Altura total da régua
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("CANCELAR"),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () async {
                          peso = aux2;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          "SALVAR",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
