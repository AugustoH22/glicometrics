import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Busca as pesquisas recentes do Firestore
  Future<List<Map<String, dynamic>>> fetchRecentSearches() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(uid)
          .doc('busca_recentes')
          .collection('recent_searches')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      // Converte os dados para uma lista de Map<String, dynamic>
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao buscar pesquisas recentes: $error');
      }
      return [];
    }
  }

  // Busca as refeições favoritas filtradas pelo tipo de refeição
  Future<List<Map<String, dynamic>>> fetchFavoriteMeals(
      String? selectedMeal) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection(uid)
          .doc('favoritos')
          .collection('c_favoritos')
          .where('selectedMeal', isEqualTo: selectedMeal)
          .get();

      // Converte os dados para uma lista de Map<String, dynamic>
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao buscar refeições favoritas: $error');
      }
      return [];
    }
  }

  // Salva uma pesquisa recente no Firestore
  Future<void> saveRecentSearch(Map<String, dynamic> foodData) async {
    try {
      await _db
          .collection(uid)
          .doc('busca_recentes')
          .collection('recent_searches')
          .add({
        'nome': foodData['nome'],
        'codigo': foodData['codigo'],
        'carboidrato_total': foodData['carboidrato_total'],
        'energia': foodData['energia'],
        'lipidios': foodData['lipidios'],
        'proteina': foodData['proteina'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao salvar pesquisa recente: $error');
      }
    }
  }

  // Busca os alimentos do Firestore
  Future<List<Map<String, dynamic>>> searchAlimentos(String query) async {
    try {
      QuerySnapshot snapshot = await _db.collection('alimentos').get();
      List<Map<String, dynamic>> resultadosExatos = [];
      List<Map<String, dynamic>> resultadosParciais = [];

      for (var doc in snapshot.docs) {
        String nomeAlimento = doc['nome'].toLowerCase();

        if (nomeAlimento == query.toLowerCase()) {
          resultadosExatos.add(doc.data() as Map<String, dynamic>);
        } else if (query
            .split(' ')
            .every((palavra) => nomeAlimento.contains(palavra))) {
          resultadosParciais.add(doc.data() as Map<String, dynamic>);
        }
      }

      return resultadosExatos + resultadosParciais;
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao buscar alimentos: $error');
      }
      return [];
    }
  }

  Future<void> salvarHipoglicemia() async {
    try {
      final DateTime now = DateTime.now();
      final TimeOfDay horaAtual = TimeOfDay.now();
      final String horaFormatada =
          '${horaAtual.hour.toString().padLeft(2, '0')}:${horaAtual.minute.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance
          .collection(uid)
          .doc('hipoglicemia')
          .collection('c_hipoglicemia')
          .add({
        'data': now, // Salva a data como um DateTime
        'hora': horaFormatada, // Salva a hora formatada como "HH:mm"
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
          'data': dados['data'],
          'hora': dados['hora'],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar o último peso: $e');
      }
    }
    return null; // Retorna null caso não haja dados
  }

  Future<void> salvarPressaoArterial({
    required int sistolica,
    required int diastolica,
    required DateTime data,
    required String hora,
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
        'hora': hora,
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
        print("Erro ao buscar dados do Firestore: $e");
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

      List<Map<String, dynamic>> historico = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return historico;
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar histórico do Firestore: $e");
      }
    }
    return [];
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
        print('Erro ao buscar histórico: $e');
      }
      return [];
    }
  }

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

  Future<void> salvarGlicemia({
    required DateTime data,
    required TimeOfDay hora,
    required String tipo,
    required String valorGlicemia,
  }) async {
    try {
      // Criar o documento de glicemia
      final glicemiaData = {
        'data': data.toIso8601String(), // Data formatada
        'hora': '${hora.hour}:${hora.minute}', // Hora formatada
        'tipo': tipo, // Tipo de glicemia (ex: jejum, pós-prandial)
        'valor': double.tryParse(valorGlicemia) ??
            0.0, // Valor da glicemia convertido para double
        'timestamp':
            FieldValue.serverTimestamp(), // Timestamp gerado pelo Firestore
      };

      // Salvar o documento na coleção 'glicemias'
      await _db
          .collection(uid)
          .doc('glicemia')
          .collection('c_glicemias')
          .add(glicemiaData);

      if (kDebugMode) {
        print('Dados de glicemia salvos com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar dados de glicemia: $e');
      }
    }
  }
}
