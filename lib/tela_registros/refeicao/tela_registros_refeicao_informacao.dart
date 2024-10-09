import 'package:flutter/material.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao_busca_alimentos.dart';

class InformacaoRefeicaoScreen extends StatefulWidget {
  final String? selectedOption;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? glicemiaValue;
  final bool? isNoGlicemia;
  final String? selectedMeal;

  const InformacaoRefeicaoScreen(
      {super.key, this.selectedOption,
      this.selectedDate,
      this.selectedTime,
      this.glicemiaValue,
      this.isNoGlicemia,
      this.selectedMeal});
  @override
  // ignore: library_private_types_in_public_api
  _InformacaoRefeicaoScreenState createState() =>
      _InformacaoRefeicaoScreenState();
}

class _InformacaoRefeicaoScreenState extends State<InformacaoRefeicaoScreen> {
  String? selectedMeal; // Para armazenar a refeição selecionada
  String? glicemiaValue = ""; // Para armazenar o valor da glicemia
  bool? isNoGlicemia =
      false; // Para armazenar o estado do switch "Sem glicemia"

  // Variável de controle para rastrear se a tela "Refeição" foi visitada
  bool refeicaoScreenVisited = false;

  @override
  void initState() {
    super.initState();
    selectedMeal = widget.selectedMeal;
    glicemiaValue = widget.glicemiaValue;
    isNoGlicemia = widget.isNoGlicemia;
  }

  bool _isNextButtonEnabled() {
    // O botão "Próximo" só habilita se uma refeição for selecionada e a glicemia estiver preenchida ou "Sem glicemia" estiver ativo
    return selectedMeal != null &&
        (glicemiaValue?.isNotEmpty == true || (isNoGlicemia ?? false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refeição'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RefeicaoScreen(
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Subtítulo com controle de navegação
                Center(
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
                          ); // Voltar para a tela anterior (Momento)
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              'Momento >',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          // Já estamos na tela de "Informação", não faz nada
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Informação >',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Tela "Refeição", só habilitada se o botão "Próximo" foi clicado ao menos uma vez
                      GestureDetector(
                        onTap: refeicaoScreenVisited
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BuscaAlimentoScreen(),
                                  ),
                                ).then((visited) {
                                  if (visited == true) {
                                    setState(() {
                                      refeicaoScreenVisited = true;
                                    });
                                  }
                                });
                              }
                            : null, // Desabilita o clique se a tela não foi visitada
                        child: Row(
                          children: [
                            Icon(Icons.restaurant,
                                color: refeicaoScreenVisited
                                    ? Colors.blue
                                    : Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Refeição >',
                              style: TextStyle(
                                fontSize: 16,
                                color: refeicaoScreenVisited
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Container para selecionar a refeição
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Momento da Refeição',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Primeira linha de containers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMealContainer('Café', Icons.coffee),
                            const SizedBox(
                                width: 60), // Espaçamento entre os containers
                            _buildMealContainer('Almoço', Icons.lunch_dining),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Segunda linha de containers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMealContainer('Janta', Icons.dinner_dining),
                            const SizedBox(
                                width: 60), // Espaçamento entre os containers
                            _buildMealContainer('Lanche', Icons.fastfood),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Container para informar o valor da glicemia
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Informe a glicemia',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          keyboardType: TextInputType.number,
                          enabled: !(isNoGlicemia ??
                              false), // Desabilita o campo se "Sem glicemia" estiver ativo
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Valor da glicemia',
                          ),
                          onChanged: (value) {
                            setState(() {
                              glicemiaValue = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Sem glicemia'),
                            Switch(
                              value: (isNoGlicemia ?? false),
                              onChanged: (value) {
                                setState(() {
                                  isNoGlicemia = value;
                                  if ((isNoGlicemia ?? false)) {
                                    glicemiaValue =
                                        ""; // Limpa o valor da glicemia se o switch for ativado
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                    height: 80), // Espaço para o botão "Próximo" no final
              ],
            ),
          ),
          // Botão "Próximo" fixo no final da tela
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isNextButtonEnabled()
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuscaAlimentoScreen(
                              selectedDate: widget.selectedDate,
                              selectedTime: widget.selectedTime,
                              selectedOption: widget.selectedOption,
                              glicemiaValue: glicemiaValue,
                              isNoGlicemia: isNoGlicemia,
                              selectedMeal: selectedMeal,
                            ),
                          ),
                        ).then((visited) {
                          if (visited == true) {
                            setState(() {
                              refeicaoScreenVisited = true;
                            });
                          }
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  disabledForegroundColor: Colors.grey.withOpacity(0.38),
                  disabledBackgroundColor: Colors.grey
                      .withOpacity(0.12), // Cor do botão quando desabilitado
                ), // Desabilita o botão se os campos não estiverem preenchidos
                child: const Text('Próximo'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função que cria o container das refeições (Café, Almoço, Janta, Lanche)
  Widget _buildMealContainer(String meal, IconData icon) {
    return SizedBox(
      width: 100, // Define a largura do quadrado
      height: 100, // Define a altura do quadrado
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMeal = meal;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
                color: selectedMeal == meal ? Colors.blue : Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selectedMeal == meal ? Colors.blue : Colors.grey,
                  size: 40),
              const SizedBox(height: 8),
              Text(
                meal,
                style: TextStyle(
                  color: selectedMeal == meal ? Colors.blue : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
