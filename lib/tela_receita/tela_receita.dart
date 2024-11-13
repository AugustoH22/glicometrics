import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
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
 
  @override
  bool get wantKeepAlive => true;
  final gemini = Gemini.instance;
  String output = '';

  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // StreamController para gerenciar a resposta da API
  final StreamController<String> _streamController = StreamController<String>.broadcast();

  Future<void> obterReceita(String input) async {
    if (input.isEmpty) return;

    setState(() {
      _controller.text = '';
      _isLoading = true;
      output = 'Pesquisando...';
    });

    final msg = input;

    try {
    gemini.streamGenerateContent(msg).listen((value) {

if (output.contains('Pesquisando...')) {
  output = '';
}
  final ot = value.output??'';
  
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
  void dispose() {
    _streamController.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);  // Importante para AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receitas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: 'Lemonada',
            fontWeight: FontWeight.w300,
          ),
        ),
        backgroundColor: const Color(0xFF1693A5),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(output.isEmpty?'Qual a boa ?':output))
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Manda bala',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    obterReceita(_controller.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
