import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  // Autenticando o usuário atual
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Função para salvar uma hipoglicemia
  Future<void> salvarHipoglicemia() async {
    try {
      final DateTime now = DateTime.now();
      final TimeOfDay horaAtual = TimeOfDay.now();
      final String horaFormatada =
          '${horaAtual.hour.toString().padLeft(2, '0')}:${horaAtual.minute.toString().padLeft(2, '0')}';

      await _db
          .collection(uid)
          .doc('hipoglicemia')
          .collection('c_hipoglicemia')
          .add({
        'data': now, // Salva a data como DateTime
        'hora': horaFormatada, // Salva a hora formatada
      });
      if (kDebugMode) {
        print('Dados de hipoglicemia salvos com sucesso.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar dados de hipoglicemia: $e');
      }
    }
  }

}
