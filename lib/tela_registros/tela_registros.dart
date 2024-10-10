import 'package:flutter/material.dart';
import 'package:main/tela_registros/glicemia/tela_registros_glicemia.dart';
import 'package:main/tela_registros/tela_registros_hipoglicemia.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao.dart';
import 'package:main/tela_registros/tela_registros_saude.dart';

// Sua tela de Registros
class RegistrosScreen extends StatefulWidget {
  const RegistrosScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrosScreenState createState() => _RegistrosScreenState();
}

class _RegistrosScreenState extends State<RegistrosScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Registros',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontFamily: 'Lemonada',
            fontWeight: FontWeight.w300,
          ),
        ),// Sem sombra
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Ação para notificações
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centraliza verticalmente os botões
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Garante que todos os botões tenham o mesmo tamanho na largura
          children: [
            _buildButton('Registrar Refeição', Icons.restaurant, Colors.orange,
                context, const RefeicaoScreen()),
            const SizedBox(height: 20), // Espaço entre os botões
            _buildButton('Registrar Glicemia', Icons.bloodtype, Colors.red,
                context, const GlicemiaScreen()),
            const SizedBox(height: 20), // Espaço entre os botões
            _buildButton('Registrar Hipoglicemia', Icons.warning, Colors.blue,
                context, const HipoglicemiaScreen()),
            const SizedBox(height: 20), // Espaço entre os botões
            _buildButton('Dados de Saúde', Icons.health_and_safety,
                Colors.green, context, const SaudeScreen()),
          ],
        ),
      ),
    );
  }

  // Função para criar botões de registro com navegação
  Widget _buildButton(String text, IconData icon, Color color,
      BuildContext context, Widget destinationScreen) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        backgroundColor: color, // Cor do botão
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
