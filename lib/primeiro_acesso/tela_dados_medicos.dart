import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:main/primeiro_acesso/tela_termos.dart';
import 'package:main/regua/simple_ruler_picker.dart';
import 'package:main/regua/simple_ruler_picker_peso.dart';

class TelaDadosMedicos extends StatefulWidget {
  final String nome;
  final String sobrenome;
  final String celular;
  final String nascimento;
  final String genero;

  const TelaDadosMedicos(
      {super.key,
      required this.nome,
      required this.sobrenome,
      required this.celular,
      required this.nascimento,
      required this.genero});

  @override
  State<TelaDadosMedicos> createState() => _TelaDadosMedicosState();
}

class _TelaDadosMedicosState extends State<TelaDadosMedicos> {
  String tipoDiabetes = "------";
  String terapia = "------";
  String usaMedicamentos = "------";
  final TextEditingController diagnosticoController = TextEditingController();

  int altura = 0;
  double peso = 0;

  bool isValid = false;

  void _validate() {
    setState(() {
      isValid = diagnosticoController.text.isNotEmpty &&
          tipoDiabetes != "------" &&
          terapia != "------" &&
          usaMedicamentos != "------" &&
          peso != 0 &&
          altura != 0;
    });
  }

  @override
  void initState() {
    super.initState();
    diagnosticoController.addListener(_validate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dados Médicos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
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
                          _validate();
                        });
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black
                                  .withAlpha(140)), // Contorno cinza claro
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            "$peso Kg",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
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
                          _validate();
                        });
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black
                                  .withAlpha(140)), // Contorno cinza claro
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            "$altura cm",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
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
                "------",
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
                  _validate();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: "Terapia*",
              value: terapia,
              items: [
                "------",
                "Caneta",
                "Seringa",
                "Bomba de Insulina",
                "Não uso Insulina",
                "Outro"
              ],
              onChanged: (value) {
                setState(() {
                  terapia = value ?? " ";
                  _validate();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: "Usa Medicamentos*",
              value: usaMedicamentos,
              items: ["------", "Sim", "Não"],
              onChanged: (value) {
                setState(() {
                  usaMedicamentos = value ?? " ";
                  _validate();
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
            Center(
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TelaTermosPrivacidade(
                              nome: widget.nome,
                              sobrenome: widget.sobrenome,
                              celular: widget.celular,
                              nascimento: widget.nascimento,
                              genero: widget.genero,
                              tipo: tipoDiabetes,
                              terapia: terapia,
                              usaMedicamentos: usaMedicamentos,
                              diagnostico: diagnosticoController.text,
                              peso: peso,
                              altura: altura,
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
            ),
          ],
        ),
      ),
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

  void _alterarAltura() {
    int aux3 = altura;
    if (aux3 == 0) {
      aux3 = 170;
    }
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
                    initialValue: aux3, // Altura inicial
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
                          _validate();
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
                    "$peso Kg",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SimpleRulerPickerPeso(
                    minValue: 200, // Valor mínimo da altura
                    maxValue: 3000, // Valor máximo da altura
                    initialValue: 1600, // Altura inicial
                    onValueChanged: (value) {
                      setState(() {
                        peso = value / 10;
                        _validate();
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
}
