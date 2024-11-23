import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para copiar texto para a área de transferência
import 'package:flutter_gemini/flutter_gemini.dart';

class ReceitaScreen extends StatefulWidget {
  const ReceitaScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReceitaScreenState createState() => _ReceitaScreenState();
}

class _ReceitaScreenState extends State<ReceitaScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final gemini = Gemini.instance;
  String output = '';
  String iaRecommendation = "Carregando recomendação...";
  final TextEditingController _controller = TextEditingController();
  String promptMessage = "Faça sua pesquisa!";

  // Método para verificar se uma linha contém `**` e formatar o texto dinamicamente
  Widget _buildFormattedText(String text) {
    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        children: text.split('\n').map((line) {
          if (line.contains('**')) {
            return TextSpan(
              text: '${line.replaceAll('**', '')}\n',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          } else {
            return TextSpan(
              text: '$line\n',
              style: const TextStyle(fontWeight: FontWeight.normal),
            );
          }
        }).toList(),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Future<void> obterRecomendacao() async {
    setState(() {
      iaRecommendation = "Carregando recomendação...";
    });

    try {
      gemini
          .streamGenerateContent(
              "Me diga apenas o nome de uma refeição bem gostosa que pode ser feita por diabeticos, sem receita")
          .listen((value) {
        setState(() {
          iaRecommendation =
              value.output ?? "Recomendação indisponível no momento.";
        });
      });
    } catch (error) {
      debugPrint('Erro ao obter recomendação: $error');
      setState(() {
        iaRecommendation =
            "Erro ao obter recomendação. Tente novamente mais tarde.";
      });
    }
  }

  Future<void> obterReceita(String input) async {
    if (input.isEmpty) return;

    // Concatenação do texto enviado ao prompt
    final String formattedInput =
        "Me gere uma resposta para o seguinte prompt caso tiver relação com receitas e culinária, caso não tiver, me retorne apenas 'Desculpe, não identifiquei o seu pedido como uma receita...': $input, lembre-se que sou diabético e não posso consumir açúcar, então por favor, me retorne uma receita que não contenha açúcar.";

    setState(() {
      _controller.text = '';
      output = '';
      promptMessage = "Pedido: $input";
    });

    try {
      gemini.streamGenerateContent(formattedInput).listen((value) {
        setState(() {
          output += value.output ?? '';
        });
      });

      setState(() {});
    } catch (error, stacktrace) {
      debugPrint('Erro ao obter resposta: $error');
      debugPrint('Stacktrace: $stacktrace');
      setState(() {
        output = 'Erro de conexão ou de processamento. Tente novamente.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obterRecomendacao();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        toolbarHeight: 100,
        title: LayoutBuilder(
          builder: (context, constraints) {
            double logoSize = constraints.maxWidth * 0.4;
            if (logoSize > 150) logoSize = 150;
            return Image.asset(
              'lib/img/receitas_logo.png',
              height: logoSize,
              width: logoSize,
              fit: BoxFit.contain,
            );
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Image.asset(
                    'lib/img/IA_Icon.png',
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Gerar uma receita com IA",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  _controller.text = iaRecommendation;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  height: 80,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6EC1E4), Color(0xFF3A93D5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildFormattedText(iaRecommendation),
                      ),
                      GestureDetector(
                        onTap: obterRecomendacao,
                        child: const Icon(
                          Icons.autorenew_sharp,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                promptMessage,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 30, // Altura mínima
                        maxHeight:
                            constraints.maxHeight, // Respeita a altura máxima
                      ),
                      child: Column(
                        children: [
                           _buildFormattedText(output),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.copy, color: Colors.blue),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: output));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Texto copiado para a área de transferência!'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (value) {
                  obterReceita(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Digite aqui a receita desejada...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send,
                  color: Color.fromARGB(255, 14, 177, 247)),
              onPressed: () {
                obterReceita(_controller.text);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
