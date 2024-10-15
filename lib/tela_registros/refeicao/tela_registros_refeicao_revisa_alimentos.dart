import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_busca_alimentos.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_informacao.dart';

class RevisaoAlimentosScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems; // Alimentos selecionados
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

  @override
  void initState() {
    super.initState();
    selectedItems = widget.selectedItems;
    _calcularNutrientes(); // Calcula os nutrientes ao iniciar
  }

  // Função para remover um item da lista
  void _removeItem(int index) {
    setState(() {
      widget.selectedItems.removeAt(index);
      _calcularNutrientes(); // Recalcula os nutrientes após remover
    });
  }

  void _calcularNutrientes() {
    totalCarboidratos = 0;
    totalProteinas = 0;
    totalGorduras = 0;
    totalCalorias = 0;

    for (var item in widget.selectedItems) {
      final alimento = item['food']; // Pegue o alimento selecionado
      final quantidade = item['quantity'] ?? 1;
      final porcao = item['porcao'] ??
          'Porção de 100g'; // Adicione a verificação da porção

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

      // Ajustar o valor com base na porção
      if (porcao == 'g') {
        // Se for em gramas, considera a quantidade direta em g
        carboidratos = (carboidratos / 100) * quantidade;
        proteinas = (proteinas / 100) * quantidade;
        gorduras = (gorduras / 100) * quantidade;
        calorias = (calorias / 100) * quantidade;
      } else if (porcao == 'kg') {
        // Se for em quilogramas, multiplica por 1000
        carboidratos = (carboidratos / 100) * (quantidade * 1000);
        proteinas = (proteinas / 100) * (quantidade * 1000);
        gorduras = (gorduras / 100) * (quantidade * 1000);
        calorias = (calorias / 100) * (quantidade * 1000);
      } else if (porcao == 'Porção de 100g') {
        // Se a porção for 100g, mantém os valores como estão, multiplicando pela quantidade
        carboidratos = carboidratos * quantidade;
        proteinas = proteinas * quantidade;
        gorduras = gorduras * quantidade;
        calorias = calorias * quantidade;
      }

      // Acumula os valores totais
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
        // Adicionado para evitar overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Row com opções de navegação no subtítulo
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tela "Momento"
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
                      }, // Desabilita o clique se a tela não foi visitada
                      child: const Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Momento >',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Tela "Informação"
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Tela "Refeição"
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
              ),
              const SizedBox(height: 20),
              const Text(
                'Itens adicionados',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap:
                    true, // Necessário para funcionar dentro de SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.selectedItems.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> alimento =
                      widget.selectedItems[index]['food'];
                  return ListTile(
                    title: Text(alimento['nome'] ?? 'Nome não disponível'),
                    subtitle: Text(
                        'Quantidade: ${widget.selectedItems[index]['quantity']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(index),
                    ),
                  );
                },
              ),
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
              Row(
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
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNutrientContainer(
                      'Carboidratos', 'g', totalCarboidratos),
                  const SizedBox(width: 8),
                  _buildNutrientContainer('Proteínas', 'g', totalProteinas),
                  const SizedBox(width: 8),
                  _buildNutrientContainer('Gorduras', 'g', totalGorduras),
                  const SizedBox(width: 8),
                  _buildNutrientContainer('Calorias', 'kcal', totalCalorias),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.selectedItems.isNotEmpty
                    ? () async {
                        try {
                          // Criar um mapa para armazenar os dados da refeição
                          Map<String, dynamic> refeicaoData = {
                            'selectedDate':
                                widget.selectedDate?.toIso8601String() ?? '',
                            'selectedTime':
                                widget.selectedTime?.format(context) ?? '',
                            'glicemiaValue': widget.glicemiaValue ?? '',
                            'isNoGlicemia': widget.isNoGlicemia ?? false,
                            'selectedMeal': widget.selectedMeal ?? '',
                            'totalCarboidratos': totalCarboidratos,
                            'totalProteinas': totalProteinas,
                            'totalGorduras': totalGorduras,
                            'totalCalorias': totalCalorias,
                            'items': widget.selectedItems.map((item) {
                              // Extrair os dados do alimento corretamente como Map<String, dynamic>
                              final Map<String, dynamic> alimentoData =
                                  item['food'];

                              return {
                                'food':
                                    alimentoData, // Usar os dados extraídos diretamente
                                'quantity': item['quantity'], // Quantidade
                                'porcao': item['porcao'] // Tipo de porção
                              };
                            }).toList(),
                          };

                          // Se a refeição for favoritada, pedir o nome
                          if (isFavorited) {
                            String nomeRefeicaoFavorita = '';
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title:
                                      const Text('Nome da Refeição Favorita'),
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

                            refeicaoData['nomeFavorito'] = nomeRefeicaoFavorita;
                            await FirebaseFirestore.instance
                                .collection('favoritos')
                                .add(refeicaoData);
                          }

                          await FirebaseFirestore.instance
                              .collection('refeicoes')
                              .add(refeicaoData);
                          if (kDebugMode) {
                            print('Refeição salva com sucesso!');
                          }

                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Sucesso'),
                                content:
                                    const Text('Refeição salva com sucesso!'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } catch (e) {
                          if (kDebugMode) {
                            print('Erro ao salvar a refeição: $e');
                          }
                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Erro'),
                                content: const Text(
                                    'Ocorreu um erro ao salvar a refeição.'),
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
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  disabledForegroundColor: Colors.grey.withOpacity(0.38),
                  disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                ),
                child: const Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Função para construir os containers de informações nutricionais
  Widget _buildNutrientContainer(String label, String unit, double value) {
    return Expanded(
      child: Container(
        height: 75,
        padding: const EdgeInsets.all(9.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${value.toStringAsFixed(2)} $unit',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ), // Exibe o valor calculado dos nutrientes
          ],
        ),
      ),
    );
  }
}
