import 'package:flutter/material.dart';

class ContaScreen extends StatefulWidget {
  const ContaScreen({super.key});

  @override
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                        'assets/images/perfil.jpg'), // Substitua pelo caminho da imagem
                  ),
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
