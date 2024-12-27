import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  // Autenticando o usuário atual
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Função para buscar o último peso registrado
  Future<Map<String, dynamic>?> buscarUltimoPeso() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(uid)
          .doc('peso')
          .collection('c_peso')
          .orderBy('data', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var dados = snapshot.docs.first.data() as Map<String, dynamic>;
        return {
          'peso': dados['peso'],
          'data': dados['data'].toDate(), // Converte para DateTime
          'hora': dados['hora'],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar o último peso: $e');
      }
    }
    return null;
  }

  // Função para salvar dados de pressão arterial
  Future<void> salvarPressaoArterial({
    required int sistolica,
    required int diastolica,
    required DateTime data,
    required TimeOfDay hora,
  }) async {
    try {
      await _db
          .collection(uid)
          .doc('pressao_arterial')
          .collection('c_pressao_arterial')
          .add({
        'sistolica': sistolica,
        'diastolica': diastolica,
        'data': data,
        'hora':
            '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
      });
      if (kDebugMode) {
        print('Pressão arterial salva com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar pressão arterial: $e');
      }
    }
  }

  // Função para buscar o histórico de pesos
  Future<List<Map<String, dynamic>>> buscarHistoricoPesos() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(uid)
          .doc('peso')
          .collection('c_peso')
          .orderBy('data', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        var dados = doc.data() as Map<String, dynamic>;
        return {
          'peso': dados['peso'],
          'data': dados['data'].toDate(),
          'hora': dados['hora'],
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar histórico de pesos: $e');
      }
      return [];
    }
  }

  // Função para salvar o peso
  Future<void> salvarPeso({required double peso}) async {
    try {
      final DateTime now = DateTime.now();
      final TimeOfDay horaAtual = TimeOfDay.now();
      final String horaFormatada =
          '${horaAtual.hour.toString().padLeft(2, '0')}:${horaAtual.minute.toString().padLeft(2, '0')}';
      await _db.collection(uid).doc('peso').collection('c_peso').add({
        'peso': peso,
        'data': now,
        'hora': horaFormatada,
      });
      if (kDebugMode) {
        print('Peso salvo com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar peso: $e');
      }
    }
  }

  // Função para salvar a altura
  Future<void> salvarAltura({required int altura}) async {
    try {
      final DateTime now = DateTime.now();
      final TimeOfDay horaAtual = TimeOfDay.now();
      final String horaFormatada =
          '${horaAtual.hour.toString().padLeft(2, '0')}:${horaAtual.minute.toString().padLeft(2, '0')}';
      await _db.collection(uid).doc('altura').collection('c_altura').add({
        'altura': altura,
        'data': now,
        'hora': horaFormatada,
      });
      if (kDebugMode) {
        print('Altura salva com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar altura: $e');
      }
    }
  }

  // Método para buscar o peso atual, o maior peso e o menor peso
  Future<Map<String, dynamic>?> getAltura() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(uid)
          .doc('altura')
          .collection('c_altura')
          .orderBy('data', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar último registro de pressão: $e");
      }
    }
    return null;
  }

  // Método para buscar o peso atual, o maior peso e o menor peso
  Future<Map<String, double>> getPesoData() async {
    try {
      // Referência para a coleção de pesos do usuário
      QuerySnapshot pesoSnapshot = await _db
          .collection(uid)
          .doc('peso')
          .collection('c_peso')
          .orderBy('data', descending: true)
          .get();

      if (pesoSnapshot.docs.isEmpty) {
        // Se não houver documentos de peso, retorne valores padrão
        return {'pesoAtual': 0, 'maiorPeso': 0, 'menorPeso': 0};
      }

      // Peso Atual: o primeiro documento no snapshot é o peso mais recente
      double pesoAtual = pesoSnapshot.docs.first['peso'] ?? 0;

      // Busca o maior e o menor peso
      double maiorPeso = pesoSnapshot.docs
          .map((doc) => doc['peso'] as double)
          .reduce((a, b) => a > b ? a : b);

      double menorPeso = pesoSnapshot.docs
          .map((doc) => doc['peso'] as double)
          .reduce((a, b) => a < b ? a : b);

      return {
        'pesoAtual': pesoAtual,
        'maiorPeso': maiorPeso,
        'menorPeso': menorPeso,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar dados de peso: $e');
      }
      return {'pesoAtual': 0, 'maiorPeso': 0, 'menorPeso': 0};
    }
  }

// Função para buscar o último registro de pressão arterial
  Future<Map<String, dynamic>?> getUltimoRegistroPressao() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(uid)
          .doc('pressao_arterial')
          .collection('c_pressao_arterial')
          .orderBy('data', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar último registro de pressão: $e");
      }
    }
    return null;
  }

  // Função para buscar o histórico de medições de pressão arterial
  Future<List<Map<String, dynamic>>> getHistoricoPressao() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(uid)
          .doc('pressao_arterial')
          .collection('c_pressao_arterial')
          .orderBy('data', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar histórico de pressão arterial: $e");
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUltimasMedicoesPressao() async {
    try {
      // Busca os últimos 7 registros de pressão, ordenados pela data
      QuerySnapshot snapshot = await _db
          .collection(uid)
          .doc('pressao_arterial')
          .collection('c_pressao_arterial')
          .orderBy('data', descending: true)
          .limit(7)
          .get();

      // Formata os dados
      return snapshot.docs.map((doc) {
        return {
          'sistolica': doc['sistolica'],
          'diastolica': doc['diastolica'],
          'data': (doc['data'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar medições de pressão: $e');
      }
      return [];
    }
  }
}
