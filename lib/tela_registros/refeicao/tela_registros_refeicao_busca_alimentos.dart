import 'package:flutter/material.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_informacao.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_revisa_alimentos.dart';

class BuscaAlimentoScreen extends StatefulWidget {
  final String? selectedOption;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? glicemiaValue;
  final bool? isNoGlicemia;
  final String? selectedMeal;

  BuscaAlimentoScreen(
      {this.selectedOption,
      this.selectedDate,
      this.selectedTime,
      this.glicemiaValue,
      this.isNoGlicemia,
      this.selectedMeal});

  @override
  _BuscaAlimentoScreenState createState() => _BuscaAlimentoScreenState();
}

class _BuscaAlimentoScreenState extends State<BuscaAlimentoScreen> {
  List<String> recentSearches = [
    'Arroz',
    'Feijão',
    'Frango'
  ]; // Exemplo de lista de buscas recentes
  int quantity = 1; // Quantidade padrão para o popup
  bool momentoScreenVisited = true;
  bool informacaoScreenVisited = true;

  // Função para mostrar o popup de detalhes do alimento
  void _showFoodPopup(String food) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(food),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: 'g', // Valor inicial do combobox
                items: ['g', 'kg'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {},
                decoration: const InputDecoration(labelText: 'Porção'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                  Text(quantity.toString(),
                      style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        quantity++;
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
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Ao confirmar, navega para a tela de revisão com o alimento selecionado
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RevisaoAlimentosScreen(
                      selectedItems: [
                        {'food': food, 'quantity': quantity}
                      ],
                      selectedDate: widget.selectedDate,
                      selectedTime: widget.selectedTime,
                      selectedOption: widget.selectedOption,
                      glicemiaValue: widget.glicemiaValue,
                      isNoGlicemia: widget.isNoGlicemia,
                      selectedMeal: widget.selectedMeal,
                    ),
                  ),
                );
                quantity = 1; // Resetar a quantidade após confirmar
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Alimento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
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
            ); // Voltar para a tela anterior
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
            // Row com opções de navegação no subtítulo
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tela "Momento", só habilitada após clicar no botão "Próximo" de telas anteriores
                  GestureDetector(
                    onTap: momentoScreenVisited
                        ? () {
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
                          }
                        : null, // Desabilita o clique se a tela não foi visitada
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
                  // Tela "Informação", só habilitada se a tela "Momento" foi visitada
                  GestureDetector(
                    onTap: informacaoScreenVisited
                        ? () {
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
                          }
                        : null, // Desabilita o clique se a tela não foi visitada
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
                  // Tela "Refeição", sempre habilitada porque estamos nessa tela
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
            // Campo de busca
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar alimento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Lógica de busca
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Buscas recentes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Lista de buscas recentes
            Expanded(
              child: ListView.builder(
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(recentSearches[index]),
                    onTap: () => _showFoodPopup(recentSearches[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
