import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  final List<Map<String, String>> _receitas = [
    {'titulo': 'Receita 1', 'descricao': 'Descrição da receita 1'},
    {'titulo': 'Receita 2', 'descricao': 'Descrição da receita 2'},
    {'titulo': 'Receita 3', 'descricao': 'Descrição da receita 3'},
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text(
            'Receitas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Lemonada',
              fontWeight: FontWeight.w300,
              height: 0,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: ShapeDecoration(
              color: const Color(0xFF1693A5),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
          ),
          actions: [
  IconButton(
    icon: FaIcon(FontAwesomeIcons.utensils), // Removido `const`
    onPressed: () {
      // Ação para notificações ou qualquer outra funcionalidade
    },
  ),
],

        ),
      ),
      body: ListView.builder(
        itemCount: _receitas.length,
        itemBuilder: (context, index) {
          final receita = _receitas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                receita['titulo'] ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(receita['descricao'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalhesReceitaScreen(
                      titulo: receita['titulo']!,
                      descricao: receita['descricao']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ação para adicionar nova receita
        },
        backgroundColor: const Color(0xFF1693A5),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DetalhesReceitaScreen extends StatelessWidget {
  final String titulo;
  final String descricao;

  const DetalhesReceitaScreen({
    super.key,
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: const Color(0xFF1693A5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              descricao,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
