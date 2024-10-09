import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(60.0), // Define a altura do AppBar
        child: AppBar(
          title: const Text(
            'GlicoMetrics',
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
    );
  }
}
