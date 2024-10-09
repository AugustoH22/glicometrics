import 'package:flutter/material.dart';

class ContaScreen extends StatefulWidget {
  const ContaScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ContaScreenState createState() => _ContaScreenState();
}

class _ContaScreenState extends State<ContaScreen>
    with AutomaticKeepAliveClientMixin {
  // Simulando o nome do usuário
  String nomeUsuario = 'João Silva';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(150.0), // Define a altura do AppBar
  child: AppBar(
    backgroundColor: const Color(0xFF1693A5),
    title: Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/images/perfil.jpg'), // Substitua pelo caminho da imagem
        ),
        const SizedBox(width: 10), // Espaçamento entre o avatar e o texto
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft, // Centraliza o conteúdo verticalmente à esquerda
            child: Text(
              'Olá, $nomeUsuario',
              style: const TextStyle(
                fontSize: 24, // Tamanho do texto
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),

      body: ListView(
        children: [
          // Reutilizamos o mesmo estilo para todos os ListTile
          _buildListItem(
            icon: Icons.person,
            text: 'Meu Perfil',
            onTap: () {
              // Ação ao clicar
            },
          ),
          _buildListItem(
            icon: Icons.notifications,
            text: 'Lembretes',
            onTap: () {
              // Ação ao clicar
            },
          ),
          _buildListItem(
            icon: Icons.local_hospital,
            text: 'Medicamentos',
            onTap: () {
              // Ação ao clicar
            },
          ),
          _buildListItem(
            icon: Icons.insert_chart,
            text: 'Relatórios',
            onTap: () {
              // Ação ao clicar
            },
          ),
          _buildListItem(
            icon: Icons.devices,
            text: 'Meus Dispositivos',
            onTap: () {
              // Ação ao clicar
            },
          ),
          _buildListItem(
            icon: Icons.privacy_tip,
            text: 'Termo e Privacidade',
            onTap: () {
              // Ação ao clicar
            },
          ),
          _buildListItem(
            icon: Icons.logout,
            text: 'Sair',
            onTap: () {
              // Ação ao clicar
            },
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
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!), // Borda cinza clara
        borderRadius: BorderRadius.circular(8.0),
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
