import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ReceitaScreen extends StatefulWidget {
  const ReceitaScreen({super.key});

  @override
  _ReceitaScreenState createState() => _ReceitaScreenState();
}

class _ReceitaScreenState extends State<ReceitaScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final gemini = Gemini.instance;
  String output = '';
  String iaRecommendation = "Carregando recomendação..."; // Texto padrão ao carregar
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String promptMessage = "Não gerou sua receita ainda? Gere agora!"; // Texto dinâmico acima da caixa de resposta

  // StreamController para gerenciar a resposta da API
  final StreamController<String> _streamController = StreamController<String>.broadcast();

  // Método para obter a recomendação inicial da IA
  Future<void> obterRecomendacao() async {
    setState(() {
      iaRecommendation = "Carregando recomendação..."; // Mostra o status enquanto carrega
    });

    try {
      // Solicita a recomendação inicial à IA
      gemini.streamGenerateContent("Me diga um nome de uma refeição bem gostosa que pode ser feita por diabeticos").listen((value) {
        setState(() {
          iaRecommendation = (value.output != null)
              ? "Que tal ${value.output}?"
              : "Recomendação indisponível no momento.";
        });
      });
    } catch (error) {
      debugPrint('Erro ao obter recomendação: $error');
      setState(() {
        iaRecommendation = "Erro ao obter recomendação. Tente novamente mais tarde.";
      });
    }
  }

  Future<void> obterReceita(String input) async {
    if (input.isEmpty) return;

    setState(() {
      _controller.text = '';
      _isLoading = true;
      output = 'Pesquisando...';
      promptMessage = "Pedido: $input"; // Atualiza o texto com o prompt do usuário
    });

    final msg = input;

    try {
      gemini.streamGenerateContent(msg).listen((value) {
        if (output.contains('Pesquisando...')) {
          output = '';
        }
        final ot = value.output ?? '';

        setState(() {
          output += ot.toString();
        });
      });

      setState(() {
        _isLoading = false;
      });
    } catch (error, stacktrace) {
      debugPrint('Erro ao obter resposta: $error');
      debugPrint('Stacktrace: $stacktrace');
      setState(() {
        output = 'Erro de conexão ou de processamento. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obterRecomendacao(); // Obtém a recomendação inicial ao iniciar o widget
  }

  @override
  void dispose() {
    _streamController.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Importante para AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Cor branca sólida
        elevation: 0, // Remove a sombra para evitar alteração de cor
        toolbarHeight: 100,
        title: LayoutBuilder(
          builder: (context, constraints) {
            double logoSize = constraints.maxWidth * 0.4;
            if (logoSize > 150) logoSize = 150; // Limita o tamanho máximo da logo
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
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Espaço para a imagem da IA e o texto personalizado "Gerar uma receita"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Image.asset(
                  'lib/img/IA_Icon.png', // Caminho da imagem personalizada
                  width: 30, // Largura da imagem, similar ao ícone anterior
                  height: 30, // Altura da imagem, similar ao ícone anterior
                ),
                const SizedBox(width: 8),
                const Text(
                  "Gerar uma receita",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Ícone de balão de conversa com recomendação de receita da IA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: obterRecomendacao, // Gera nova recomendação ao clicar no ícone
                  child: Icon(Icons.published_with_changes_outlined, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Copia a recomendação para a caixa de pesquisa
                      _controller.text = iaRecommendation;
                    },
                    child: Container(
                      width: double.infinity,
                      height: 80, // Altura fixa para a caixa de recomendação
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          iaRecommendation,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Texto dinâmico acima da caixa de resposta da IA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              promptMessage,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          const SizedBox(height: 5),
          // Caixa de resposta da IA com altura fixa e rolagem interna
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: 250, // Altura fixa para a caixa de resposta
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white, // Caixa de resposta branca
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: _buildFormattedText(
                    output.isEmpty ? "Você pode visualizar aqui a sua receita gerada!" : output,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Caixa de entrada de texto e botão enviar fixados na parte inferior
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) {
                      obterReceita(value); // Chama a função ao pressionar Enter
                    },
                    decoration: const InputDecoration(
                      labelText: 'Digite a receita desejada...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color.fromARGB(255, 153, 54, 15)),
                  onPressed: () {
                    obterReceita(_controller.text);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      backgroundColor: Colors.white, // Fundo branco para combinar com AppBar e caixa de resposta
    );
  }

  // Método para construir o texto com linhas específicas em negrito e tamanho maior
  Widget _buildFormattedText(String text) {
    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        children: _formatOutput(text),
        style: const TextStyle(color: Colors.black, fontSize: 18), // Aumenta o tamanho do texto
      ),
    );
  }

  // Método para formatar o output, aplicando negrito nas linhas que contêm '**' e mantendo quebras de linha
  List<TextSpan> _formatOutput(String text) {
    return text.split('\n').map((line) {
      if (line.contains('**')) {
        return TextSpan(
          text: line.replaceAll('**', '') + '\n',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Aumenta o tamanho do texto em negrito
        );
      } else {
        return TextSpan(text: line + '\n', style: const TextStyle(fontSize: 16)); // Aumenta o tamanho do texto normal
      }
    }).toList();
  }
}
