import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_revisa_alimentos.dart';

class BuscaAlimentoScreen extends StatefulWidget {
  final String? selectedOption;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? glicemiaValue;
  final bool? isNoGlicemia;
  final String? selectedMeal;
  final List<Map<String, dynamic>>? selectedItems;

  const BuscaAlimentoScreen(
      {super.key,
      this.selectedOption,
      this.selectedDate,
      this.selectedTime,
      this.glicemiaValue,
      this.isNoGlicemia,
      this.selectedMeal,
      required this.selectedItems});

  @override
  // ignore: library_private_types_in_public_api
  _BuscaAlimentoScreenState createState() => _BuscaAlimentoScreenState();
}

class _BuscaAlimentoScreenState extends State<BuscaAlimentoScreen> {
  List<Map<String, dynamic>> recentSearches = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> favoriteMeals = [];
  bool isLoading = false;
  int quantity = 1;
  List<Map<String, dynamic>>? selectedItems;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    selectedItems = widget.selectedItems;
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchRecentSearches();
    await _fetchFavoriteMeals();
  }

  Future<void> _fetchRecentSearches() async {
    List<Map<String, dynamic>> results = await _firestoreService.fetchRecentSearches();
    setState(() {
      recentSearches = results;
    });
  }

  Future<void> _fetchFavoriteMeals() async {
    List<Map<String, dynamic>> meals = await _firestoreService.fetchFavoriteMeals(widget.selectedMeal);
    setState(() {
      favoriteMeals = meals;
    });
  }

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

    List<Map<String, dynamic>> results = await _firestoreService.searchAlimentos(query);

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  void _showFoodPopup(BuildContext context, Map<String, dynamic> food) {
    int localQuantity = quantity;
    String porcao = 'Porção de 100g';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(food['nome']),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: 'Porção de 100g',
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
                            if (localQuantity > 1) localQuantity--;
                          });
                        },
                      ),
                      Text(localQuantity.toString(),
                          style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setStateDialog(() {
                            localQuantity++;
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
                    _addFoodToSelection(food, porcao, localQuantity);
                    Navigator.of(context).pop();
                    _navigateToRevisaoAlimentosScreen(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addFoodToSelection(Map<String, dynamic> food, String porcao, int localQuantity) {
    setState(() {
      selectedItems!.add({
        'porcao': porcao,
        'food': food,
        'quantity': localQuantity,
      });
      _firestoreService.saveRecentSearch(food); // Salvar a pesquisa recente
    });
  }

  void _navigateToRevisaoAlimentosScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RevisaoAlimentosScreen(
          selectedItems: selectedItems!,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          selectedOption: widget.selectedOption,
          glicemiaValue: widget.glicemiaValue,
          isNoGlicemia: widget.isNoGlicemia,
          selectedMeal: widget.selectedMeal,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _processFavoriteMealItems(List<dynamic> mealData) {
    List<Map<String, dynamic>> selectedItemsFromFav = [];

    for (var alimento in mealData) {
      selectedItemsFromFav.add({
        'food': alimento['food'] ?? 'Desconhecido', // Prevenção de nulos
        'quantity': alimento['quantity'] ?? 1, // Prevenção de nulos
        'porcao': alimento['porcao'] ?? 'Porção não definida', // Prevenção de nulos
      });
    }

    return selectedItemsFromFav;
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
              Navigator.of(context).popUntil((route) => route.isFirst);
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
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar alimento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchAlimentos(value);
              },
            ),
            const SizedBox(height: 20),
            const Text('Pesquisas Recentes'),
            Wrap(
              children: recentSearches
                  .map((search) => GestureDetector(
                        onTap: () => _showFoodPopup(context, search),
                        child: Chip(label: Text(search['nome'] ?? 'Nome não disponível')),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Refeições Favoritas'),
            Expanded(
              child: ListView.builder(
                itemCount: favoriteMeals.length,
                itemBuilder: (context, index) {
                  final meal = favoriteMeals[index];
                  final List<Map<String, dynamic>> items = _processFavoriteMealItems(meal['items']);

                  return ListTile(
                    title: Text(meal['nome'] ?? 'Nome desconhecido'),
                    onTap: () => _loadFavoriteMeal(items),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: searchResults.isNotEmpty
                        ? ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final alimento = searchResults[index];
                              return ListTile(
                                title: Text(alimento['nome']),
                                onTap: () => _showFoodPopup(context, alimento),
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

  void _loadFavoriteMeal(List<Map<String, dynamic>> mealData) {
    if (mealData.isNotEmpty) {
      List<Map<String, dynamic>> selectedItemsFromFav = [];

      for (var alimento in mealData) {
        selectedItemsFromFav.add({
          'food': alimento['food'] ?? 'Desconhecido',
          'quantity': alimento['quantity'] ?? 1,
          'porcao': alimento['porcao'] ?? 'Porção não definida',
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RevisaoAlimentosScreen(
            selectedItems: selectedItemsFromFav,
            selectedDate: widget.selectedDate,
            selectedTime: widget.selectedTime,
            selectedOption: widget.selectedOption,
            glicemiaValue: widget.glicemiaValue,
            isNoGlicemia: widget.isNoGlicemia,
            selectedMeal: widget.selectedMeal,
          ),
        ),
      );
    }
  }
}
