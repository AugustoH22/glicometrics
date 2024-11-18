import 'package:flutter/material.dart';
import 'package:main/tela_registros/glicemia/tela_registros_glicemia.dart';
import 'package:main/tela_registros/hipoglicemia/tela_registros_hipoglicemia.dart';
import 'package:main/tela_registros/refeicao/tela_registros_refeicao.dart';
import 'package:main/tela_registros/saude/tela_registros_saude.dart';

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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Cor branca sólida
        elevation: 0, // Remove a sombra para evitar alteração de cor
        toolbarHeight: 100,
        title: LayoutBuilder(
          builder: (context, constraints) {
            double logoSize = constraints.maxWidth * 0.4;
            if (logoSize > 150) logoSize = 150; // Limita o tamanho máximo da logo
            return Image.asset(
              'lib/img/registros_logo.png',
              height: logoSize,
              width: logoSize,
              fit: BoxFit.contain,
            );
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centraliza verticalmente os botões
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Garante que todos os botões tenham o mesmo tamanho na largura
          children: [
            _buildButton('Registrar Refeição', Icons.restaurant, const Color.fromARGB(255, 244, 239, 239),
                context, const RefeicaoScreen()),
            const SizedBox(height: 20), // Espaço entre os botões
            _buildButton('Registrar Glicemia', Icons.bloodtype, const Color.fromARGB(255, 244, 239, 239),
                context, const GlicemiaScreen()),
            const SizedBox(height: 20), // Espaço entre os botões
            _buildButtonWithPopup('Registrar Hipoglicemia', Icons.warning, const Color.fromARGB(255, 244, 239, 239)),
            const SizedBox(height: 20), // Espaço entre os botões
            _buildButton('Dados de Saúde', Icons.health_and_safety,
                const Color.fromARGB(255, 244, 239, 239), context, const SaudeScreen()),
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
      icon: Icon(icon, size: 28, color: Colors.grey),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  // Função para criar botão com popup de confirmação para Hipoglicemia
  Widget _buildButtonWithPopup(String text, IconData icon, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        backgroundColor: color, // Cor do botão
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Bordas arredondadas
        ),
      ),
      onPressed: () {
        _showConfirmDialog(context);
      },
      icon: Icon(icon, size: 28, color: Colors.grey),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  // Função para mostrar o diálogo de confirmação
  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registrar Hipoglicemia'),
          content: const Text('Você gostaria de registrar uma hipoglicemia?'),
          actions: [
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o popup
              },
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o popup
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HipoglicemiaScreen(),
                  ),
                ); // Redireciona para a tela de Hipoglicemia
              },
            ),
          ],
        );
      },
    );
  }
}
