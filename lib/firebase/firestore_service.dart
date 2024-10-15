import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Busca as pesquisas recentes do Firestore
  Future<List<Map<String, dynamic>>> fetchRecentSearches() async {
    try {
      QuerySnapshot snapshot = await _db
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
          .collection('favoritos')
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
      await _db.collection('recent_searches').add({
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
      await _db.collection('glicemias').add(glicemiaData);

      print('Dados de glicemia salvos com sucesso!');
    } catch (e) {
      print('Erro ao salvar dados de glicemia: $e');
    }
  }
}
