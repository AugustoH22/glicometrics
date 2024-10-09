import 'package:flutter/material.dart';
import 'package:main/tela_registros/glicemia/tela_registros_glicemia.dart';
import 'package:main/tela_registros/tela_registros_hipoglicemia.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao.dart';
import 'package:main/tela_registros/tela_registros_saude.dart';

// Sua tela de Registros
class RegistrosScreen extends StatefulWidget {
  const RegistrosScreen({super.key});

  @override
  _RegistrosScreenState createState() => _RegistrosScreenState();
}

class _RegistrosScreenState extends State<RegistrosScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Define a altura do AppBar
        child: AppBar(
          title: const Text(
            'Registros',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Lemonada',
              fontWeight: FontWeight.w300,
              height: 0,
            ),
          ),
          backgroundColor: Colors.transparent, // Cor de fundo transparente
          elevation: 0, // Sem sombra
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
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Ação para notificações
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente os botões
          crossAxisAlignment: CrossAxisAlignment.stretch, // Garante que todos os botões tenham o mesmo tamanho na largura
          children: [
            _buildButton('Registrar Refeição', Icons.restaurant, Colors.orange, context, RefeicaoScreen()),
            const SizedBox(height: 20), // Espaço entre os botões
            _buildButton('Registrar Glicemia', Icons.bloodtype, Colors.red, context, GlicemiaScreen()),
            const SizedBox(height: 20), // Espaço entre os botões
            _buildButton('Registrar Hipoglicemia', Icons.warning, Colors.blue, context, HipoglicemiaScreen()),
            const SizedBox(height: 20), // Espaço entre os botões
            _buildButton('Dados de Saúde', Icons.health_and_safety, Colors.green, context, SaudeScreen()),
          ],
        ),
      ),
    );
  }

  // Função para criar botões de registro com navegação
  Widget _buildButton(String text, IconData icon, Color color, BuildContext context, Widget destinationScreen) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15.0), backgroundColor: color, // Cor do botão
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Bordas arredondadas
        ),
      ),
      onPressed: () {
        // Navegar para a tela correspondente
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
      icon: Icon(icon, size: 28, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
