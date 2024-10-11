import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_revisa_alimentos.dart';

class BuscaAlimentoScreen extends StatefulWidget {
  final String? selectedOption;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? glicemiaValue;
  final bool? isNoGlicemia;
  final String? selectedMeal;

  const BuscaAlimentoScreen(
      {super.key,
      this.selectedOption,
      this.selectedDate,
      this.selectedTime,
      this.glicemiaValue,
      this.isNoGlicemia,
      this.selectedMeal});

  @override
  _BuscaAlimentoScreenState createState() => _BuscaAlimentoScreenState();
}

class _BuscaAlimentoScreenState extends State<BuscaAlimentoScreen> {
  List<String> recentSearches = ['Arroz', 'Feijão', 'Frango']; // Lista de buscas recentes (inicial)
  List<dynamic> searchResults = []; // Lista de resultados da busca
  bool isLoading = false; // Indicador de carregamento
  int quantity = 1; // Quantidade padrão para o popup

  // Função para processar a query (ignora maiúsculas/minúsculas e separa as palavras)
  List<String> processQuery(String query) {
    return query.toLowerCase().split(' ').where((word) => word.isNotEmpty).toList();
  }

  // Função para buscar alimentos do Firestore
  Future<void> _searchAlimentos(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Processar a query para separar palavras relevantes
      List<String> processedQuery = processQuery(query);

      // Fazer a busca no Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('alimentos').get();

      // Listas para separar resultados exatos e parciais
      List<dynamic> resultadosExatos = [];
      List<dynamic> resultadosParciais = [];

      // Filtrar os resultados no cliente com base nas palavras da query
      for (var doc in snapshot.docs) {
        String nomeAlimento = doc['nome'].toLowerCase();

        // Verificar se o nome corresponde exatamente à query
        if (nomeAlimento == query.toLowerCase()) {
          resultadosExatos.add(doc);
        } else if (processedQuery.every((palavra) => nomeAlimento.contains(palavra))) {
          // Se não for exato, verificar se contém todas as palavras da query
          resultadosParciais.add(doc);
        }
      }

      // Unir os resultados exatos com os parciais, dando prioridade aos exatos
      List<dynamic> resultadosFinais = resultadosExatos + resultadosParciais;

      setState(() {
        searchResults = resultadosFinais;
      });
    } catch (error) {
      print('Erro ao buscar alimentos: $error');
      setState(() {
        searchResults = [];
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Ocorreu um erro ao buscar os alimentos. Tente novamente mais tarde.'),
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
                  Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
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
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst); // Voltar para a tela de registros
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
            // Campo de busca
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar alimento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchAlimentos(value); // Chama a função de busca desde a primeira letra
              },
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator() // Indicador de carregamento
                : Expanded(
                    child: searchResults.isNotEmpty
                        ? ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final alimento = searchResults[index];
                              return ListTile(
                                title: Text(alimento['nome']),
                                onTap: () => _showFoodPopup(alimento['nome']),
                              );
                            },
                          )
                        : const Text('Nenhum alimento encontrado'),
                  ),
          ],
        ),
      ),
    );
  }
}
