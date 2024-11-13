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

  final String apiKey =
      '';
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;
StreamController<Candidates> _streamController = StreamController<Candidates>.broadcast();

  @override
  void initState() {
    super.initState();
  
  }
  

  Future<void> obterReceita(String input) async {
    if (input.isEmpty) return;

   

    setState(() {
      _controller.text = '';
      _isLoading = true;
      _response = '';
    });

    final msg =
        '$input';
    



    try {
gemini.streamGenerateContent(msg,

generationConfig: GenerationConfig(

  
)
).listen((value) {

  final ot = value.output??'';
  
  setState(() {
    output += ot.toString();
  });
});

//     final teste = await   gemini.text(msg,
//     generationConfig: GenerationConfig(
//       maxOutputTokens: 300
//     )
//     )
//   ;

// final teste2 = teste?.toJson();
//   log(teste?.output??'aaa');

//   output = teste?.output??'';
  //     gemini.streamGenerateContent(msg)
  // .listen((value) {
  //   print(value.output);
  // }).onError((e) {
  //   log('streamGenerateContent exception', error: e);
  // });


      // final response = await openAI.onChatCompletion(request: request);
      setState(() {
        //  _response = response?.choices.last.message?.content.trim() ?? 'Erro ao processar resposta';
        _isLoading = false;
      });
    } catch (error, stacktrace) {
      debugPrint('Erro ao obter resposta: $error');
      debugPrint('Stacktrace: $stacktrace');
      setState(() {
        _response = 'Erro de conexão ou de processamento. Tente novamente.';
        _isLoading = false;
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              child: _response.isNotEmpty
                  ? Text(
                      _response,
                      style: const TextStyle(fontSize: 16),
                    )
                  :  Center(
                      child:
                          AnimatedContainer(
                            
                            duration: Duration(seconds: 1),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical  ,
                              child: Text(output.isEmpty? "Qual a boa para hoje?":output)),),),
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
