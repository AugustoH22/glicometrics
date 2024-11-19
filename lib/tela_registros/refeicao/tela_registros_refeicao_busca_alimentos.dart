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

  const BuscaAlimentoScreen({
    super.key,
    this.selectedOption,
    this.selectedDate,
    this.selectedTime,
    this.glicemiaValue,
    this.isNoGlicemia,
    this.selectedMeal,
    required this.selectedItems,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BuscaAlimentoScreenState createState() => _BuscaAlimentoScreenState();
}

class _BuscaAlimentoScreenState extends State<BuscaAlimentoScreen> {
  List<Map<String, dynamic>> recentSearches = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> favoriteMeals = [];
  bool isLoading = false;
  bool isSearching = false; // Controle de exibição
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
        isSearching = false; // Mostrar pesquisas recentes e favoritas novamente
      });
      return;
    }

    setState(() {
      isSearching = true; // Ocultar pesquisas recentes e favoritas
      isLoading = true;
    });

    List<Map<String, dynamic>> results = await _firestoreService.searchAlimentos(query);

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  void _addFoodToSelection(Map<String, dynamic> food, String porcao, int localQuantity) {
    setState(() {
      selectedItems!.add({
        'porcao': porcao,
        'food': food,
        'quantity': localQuantity,
      });

      // Verificar se a pesquisa já está nas pesquisas recentes
      if (!recentSearches.any((recent) => recent['nome'] == food['nome'])) {
        recentSearches.add(food);
        _firestoreService.saveRecentSearch(food); // Salvar a pesquisa recente
      }
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
            if (!isSearching) ...[
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
                    return ListTile(
                      title: Text(meal['nome'] ?? 'Nome desconhecido'),
                      onTap: () => _navigateToRevisaoAlimentosScreen(context),
                    );
                  },
                ),
              ),
            ],
            if (isSearching)
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchResults.isNotEmpty
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
                        : const Center(child: Text('Nenhum alimento encontrado')),
              ),
          ],
        ),
      ),
    );
  }
}
