import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_busca_alimentos.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_informacao.dart';

class RevisaoAlimentosScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final String? porcao;
  final String? selectedOption;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? glicemiaValue;
  final bool? isNoGlicemia;
  final String? selectedMeal;

  const RevisaoAlimentosScreen(
      {super.key,
      this.selectedOption,
      this.selectedDate,
      this.selectedTime,
      this.glicemiaValue,
      this.isNoGlicemia,
      this.selectedMeal,
      this.porcao,
      required this.selectedItems});

  @override
  // ignore: library_private_types_in_public_api
  _RevisaoAlimentosScreenState createState() => _RevisaoAlimentosScreenState();
}

class _RevisaoAlimentosScreenState extends State<RevisaoAlimentosScreen> {
  bool isFavorited = false; // Estado do switch de favoritar refeição
  List<Map<String, dynamic>>? selectedItems;
  double totalCarboidratos = 0;
  double totalProteinas = 0;
  double totalGorduras = 0;
  double totalCalorias = 0;

  final FirestoreService _firestoreService =
      FirestoreService(); // Instância do FirestoreService

  @override
  void initState() {
    super.initState();
    selectedItems = widget.selectedItems;
    _calcularNutrientes();
  }

  void _calcularNutrientes() {
    totalCarboidratos = 0;
    totalProteinas = 0;
    totalGorduras = 0;
    totalCalorias = 0;

    for (var item in widget.selectedItems) {
      final alimento = item['food'];
      final quantidade = item['quantity'] ?? 1;
      final porcao = item['porcao'] ?? 'Porção de 100g';

      double carboidratos = double.tryParse(
              alimento['carboidrato_total'].replaceAll(',', '.') ?? '0') ??
          0;
      double proteinas =
          double.tryParse(alimento['proteina'].replaceAll(',', '.') ?? '0') ??
              0;
      double gorduras =
          double.tryParse(alimento['lipidios'].replaceAll(',', '.') ?? '0') ??
              0;
      double calorias =
          double.tryParse(alimento['energia'].replaceAll(',', '.') ?? '0') ?? 0;

      // Ajustar os valores com base na porção
      if (porcao == 'g') {
        carboidratos = (carboidratos / 100) * quantidade;
        proteinas = (proteinas / 100) * quantidade;
        gorduras = (gorduras / 100) * quantidade;
        calorias = (calorias / 100) * quantidade;
      } else if (porcao == 'kg') {
        carboidratos = (carboidratos / 100) * (quantidade * 1000);
        proteinas = (proteinas / 100) * (quantidade * 1000);
        gorduras = (gorduras / 100) * (quantidade * 1000);
        calorias = (calorias / 100) * (quantidade * 1000);
      } else if (porcao == 'Porção de 100g') {
        carboidratos *= quantidade;
        proteinas *= quantidade;
        gorduras *= quantidade;
        calorias *= quantidade;
      }

      totalCarboidratos += carboidratos;
      totalProteinas += proteinas;
      totalGorduras += gorduras;
      totalCalorias += calorias;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Refeição Selecionada'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BuscaAlimentoScreen(
                  glicemiaValue: widget.glicemiaValue,
                  isNoGlicemia: widget.isNoGlicemia,
                  selectedMeal: widget.selectedMeal,
                  selectedDate: widget.selectedDate,
                  selectedTime: widget.selectedTime,
                  selectedOption: widget.selectedOption,
                  selectedItems: selectedItems ?? [],
                ),
              ),
            );
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildNavegacaoMomentoInformacao(),
              const SizedBox(height: 20),
              const Text(
                'Itens adicionados',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildListaAlimentos(),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuscaAlimentoScreen(
                          glicemiaValue: widget.glicemiaValue,
                          isNoGlicemia: widget.isNoGlicemia,
                          selectedMeal: widget.selectedMeal,
                          selectedDate: widget.selectedDate,
                          selectedTime: widget.selectedTime,
                          selectedOption: widget.selectedOption,
                          selectedItems: selectedItems ?? [],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Adicionar alimento',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSwitchFavorito(),
              const SizedBox(height: 20),
              _buildNutrientes(),
              const SizedBox(height: 20),
              _buildSalvarButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _editItem(int index) {
    Map<String, dynamic> currentItem = widget.selectedItems[index];
    String porcao = currentItem['porcao'];
    int quantidade = currentItem['quantity'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(currentItem['food']['nome'] ?? 'Alimento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: porcao,
                    items: ['g', 'kg', 'Porção de 100g'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        porcao = value ?? 'Porção de 100g';
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Porção'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setStateDialog(() {
                            if (quantidade > 1) quantidade--;
                          });
                        },
                      ),
                      Text(
                        quantidade.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setStateDialog(() {
                            quantidade++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    // Atualizar os valores no item selecionado
                    setState(() {
                      widget.selectedItems[index]['porcao'] = porcao;
                      widget.selectedItems[index]['quantity'] = quantidade;
                      _calcularNutrientes(); // Recalcular os valores nutricionais
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Função para remover um item da lista
  void _removeItem(int index) {
    setState(() {
      widget.selectedItems.removeAt(index);
      _calcularNutrientes();
    });
  }

  // Função para construir o botão de salvar
  Widget _buildSalvarButton() {
    return ElevatedButton(
      onPressed: widget.selectedItems.isNotEmpty
          ? () async {
              DateTime dataComHora = widget.selectedDate?.copyWith(
                    hour: widget.selectedTime?.hour,
                    minute: widget.selectedTime?.minute,
                    second:
                        0, // Você pode ajustar para outros valores se necessário
                    millisecond: 0,
                    microsecond: 0,
                  ) ??
                  DateTime.now();
              try {
                Map<String, dynamic> refeicaoData = {
                  'selectedDate': dataComHora,
                  'selectedTime': widget.selectedTime?.format(context) ?? '',
                  'glicemiaValue': widget.glicemiaValue ?? '',
                  'isNoGlicemia': widget.isNoGlicemia ?? false,
                  'selectedMeal': widget.selectedMeal ?? '',
                  'totalCarboidratos': totalCarboidratos,
                  'totalProteinas': totalProteinas,
                  'totalGorduras': totalGorduras,
                  'totalCalorias': totalCalorias,
                  'items': widget.selectedItems.map((item) {
                    final Map<String, dynamic> alimentoData = item['food'];
                    return {
                      'food': alimentoData,
                      'quantity': item['quantity'],
                      'porcao': item['porcao']
                    };
                  }).toList(),
                };

                if (isFavorited) {
                  String nomeRefeicaoFavorita = '';
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Nome da Refeição Favorita'),
                        content: TextField(
                          onChanged: (value) {
                            nomeRefeicaoFavorita = value;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Digite o nome da refeição',
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );

                  // Salvar refeição favorita no Firestore
                  await _firestoreService.salvarRefeicaoFavorita(
                      nomeRefeicaoFavorita, refeicaoData);
                } else {
                  // Salvar refeição no Firestore
                  await _firestoreService.salvarRefeicao(refeicaoData);
                }

                _showSuccessDialog();
              } catch (e) {
                _showErrorDialog();
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        disabledForegroundColor: Colors.grey.withOpacity(0.38),
        disabledBackgroundColor: Colors.grey.withOpacity(0.12),
      ),
      child: const Text('Salvar'),
    );
  }

  // Função para mostrar um dialogo de sucesso
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: const Text('Refeição salva com sucesso!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Função para mostrar um dialogo de erro
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: const Text('Ocorreu um erro ao salvar a refeição.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Função para construir o switch de favoritar refeição
  Widget _buildSwitchFavorito() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Favoritar refeição'),
        Switch(
          value: isFavorited,
          onChanged: (value) {
            setState(() {
              isFavorited = value;
            });
          },
        ),
      ],
    );
  }

  // Função para construir os containers de informações nutricionais
  Widget _buildNutrientes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNutrientContainer('Carboidratos', 'g', totalCarboidratos),
        const SizedBox(width: 8),
        _buildNutrientContainer('Proteínas', 'g', totalProteinas),
        const SizedBox(width: 8),
        _buildNutrientContainer('Gorduras', 'g', totalGorduras),
        const SizedBox(width: 8),
        _buildNutrientContainer('Calorias', 'kcal', totalCalorias),
      ],
    );
  }

  Widget _buildNutrientContainer(String label, String unit, double value) {
    return Expanded(
      child: Container(
        height: 75,
        padding: const EdgeInsets.all(7.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${value.toStringAsFixed(2)} $unit',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir a lista de alimentos
  Widget _buildListaAlimentos() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.selectedItems.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> alimento =
            widget.selectedItems[index]['food'];

        return ListTile(
          title: Text(alimento['nome'] ?? 'Nome não disponível'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
            children: [
              Text('Porção: ${widget.selectedItems[index]['porcao']}'),
              Text('Quantidade: ${widget.selectedItems[index]['quantity']}'),
            ],
          ),
          trailing: SizedBox(
            width: 60, // Limita a largura do trailing para evitar overflow
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Alinha ícones à direita
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _editItem(index), // Altere conforme necessário
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        _removeItem(index), // Altere conforme necessário
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Função para construir a navegação entre momentos
  Widget _buildNavegacaoMomentoInformacao() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RefeicaoScreen(
                    selectedDate: widget.selectedDate,
                    selectedTime: widget.selectedTime,
                    selectedOption: widget.selectedOption,
                  ),
                ),
              );
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InformacaoRefeicaoScreen(
                    glicemiaValue: widget.glicemiaValue,
                    isNoGlicemia: widget.isNoGlicemia,
                    selectedMeal: widget.selectedMeal,
                    selectedDate: widget.selectedDate,
                    selectedTime: widget.selectedTime,
                    selectedOption: widget.selectedOption,
                  ),
                ),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Informação >',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {},
            child: const Row(
              children: [
                Icon(Icons.restaurant, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  'Refeição >',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
