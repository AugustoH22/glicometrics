import 'package:flutter/material.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_busca_alimentos.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_informacao.dart';

class RevisaoAlimentosScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems; // Alimentos selecionados
  final String? selectedOption;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? glicemiaValue;
  final bool? isNoGlicemia;
  final String? selectedMeal;

  RevisaoAlimentosScreen(
      {this.selectedOption,
      this.selectedDate,
      this.selectedTime,
      this.glicemiaValue,
      this.isNoGlicemia,
      this.selectedMeal, 
      required this.selectedItems});

  @override
  _RevisaoAlimentosScreenState createState() => _RevisaoAlimentosScreenState();
}

class _RevisaoAlimentosScreenState extends State<RevisaoAlimentosScreen> {
  bool isFavorited = false; // Estado do switch de favoritar refeição

  // Variáveis de controle para rastrear se as telas foram visitadas
  bool momentoScreenVisited = true;
  bool informacaoScreenVisited = true;

  // Função para remover um item da lista
  void _removeItem(int index) {
    setState(() {
      widget.selectedItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refeição Selecionada'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuscaAlimentoScreen(),
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
            // Lista de itens adicionados
            const Text(
              'Itens adicionados',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Expanda a ListView dentro de um Container com altura definida
            Container(
              height: 200, // Defina a altura da ListView
              child: ListView.builder(
                itemCount: widget.selectedItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.selectedItems[index]['food']),
                    subtitle: Text(
                        'Quantidade: ${widget.selectedItems[index]['quantity']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(index),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // "Adicionar alimento" centralizado
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Voltar para a tela de busca
                },
                child: const Text(
                  'Adicionar alimento',
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Switch "Favoritar refeição"
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
            // Containers com informações nutricionais, todos com tamanho igual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientContainer('Carboidratos', 'g'),
                const SizedBox(width: 8),
                _buildNutrientContainer('Proteínas', 'g'),
                const SizedBox(width: 8),
                _buildNutrientContainer('Gorduras', 'g'),
                const SizedBox(width: 8),
                _buildNutrientContainer('Calorias', 'kcal'),
              ],
            ),
            const SizedBox(height: 20),
            // Botão "Salvar" no final da tela
            ElevatedButton(
              onPressed: widget.selectedItems.isNotEmpty
                  ? () {
                      // Aqui você pode adicionar a lógica para salvar a refeição
                      // Atualizar o estado de que as telas anteriores foram visitadas
                      setState(() {
                        momentoScreenVisited = true;
                        informacaoScreenVisited = true;
                      });
                    }
                  : null,
              child: const Text('Salvar'),
              style: ElevatedButton.styleFrom(
                disabledForegroundColor: Colors.grey.withOpacity(0.38),
                disabledBackgroundColor: Colors.grey
                    .withOpacity(0.12), // Cor do botão quando desabilitado
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir os containers de informações nutricionais
  Widget _buildNutrientContainer(String label, String unit) {
    return Expanded(
      child: Container(
        height: 75,
        padding: const EdgeInsets.all(10.0),
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
                '0 $unit'), // Exemplo de valor (você pode modificar com dados reais)
          ],
        ),
      ),
    );
  }
}
