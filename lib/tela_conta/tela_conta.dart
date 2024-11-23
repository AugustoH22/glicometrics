import 'package:flutter/material.dart';
import 'package:main/autentificacao/auth_service.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/tela_conta/tela_meu_perfil.dart';
import 'package:main/tela_conta/tela_termo.dart';

class ContaScreen extends StatefulWidget {
  const ContaScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ContaScreenState createState() => _ContaScreenState();
}

class _ContaScreenState extends State<ContaScreen>
    with AutomaticKeepAliveClientMixin {
  // Simulando o nome do usuário
  String nomeUsuario = '';
  Map<String, dynamic>? dadosPessoais = {};
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  Future<void> _buscarDados() async {
    dadosPessoais = await _firestoreService.getDadosPessoais();

    setState(() {
      nomeUsuario = dadosPessoais?['nome'] ?? 'Usuário';
    });

  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: const Border(
                bottom: BorderSide(color: Colors.grey), // Borda cinza clara
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 45.0),
              child: Row(
                children: [
                  const SizedBox(
                      width: 10), // Espaçamento entre o avatar e o texto
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Olá, $nomeUsuario',
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero, // Remove o padding padrão do ListView
              children: [
                _buildListItem(
                  icon: Icons.person,
                  text: 'Meu Perfil',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DadosPessoaisPage(),
                      ),
                    );
                  },
                ),
                _buildListItem(
                  icon: Icons.privacy_tip,
                  text: 'Termo e Privacidade',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermosEPrivacidadeScreen(),
                      ),
                    );
                  },
                ),
                _buildListItem(
                  icon: Icons.logout,
                  text: 'Sair',
                  onTap: () {
                    AuthService().deslogar();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Função para criar cada item da lista com borda e seta
  Widget _buildListItem(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey), // Borda cinza clara
        ),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios), // Seta
        onTap: onTap,
      ),
    );
  }
}
