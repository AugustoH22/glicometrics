import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  // Autenticando o usuário atual
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Função para buscar as pesquisas recentes do Firestore
  Future<List<Map<String, dynamic>>> fetchRecentSearches() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(uid) // Usando o UID do usuário autenticado
          .doc('busca_recentes')
          .collection('recent_searches')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

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

  // Função para buscar as refeições favoritas filtradas por tipo de refeição
  Future<List<Map<String, dynamic>>> fetchFavoriteMeals(
      String? selectedMeal) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection(uid)
          .doc('favoritos')
          .collection('c_favoritos')
          .where('selectedMeal', isEqualTo: selectedMeal)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao buscar refeições favoritas: $error');
      }
      return [];
    }
  }

  // Função para salvar uma pesquisa recente no Firestore
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

  // Função para buscar alimentos a partir de uma pesquisa
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
  
  // Função para salvar a refeição no banco de dados
  Future<void> salvarRefeicao(Map<String, dynamic> refeicaoData) async {
    try {
      await _db
          .collection(uid)
          .doc('refeicoes')
          .collection('c_refeicoes')
          .add(refeicaoData);

      if (refeicaoData['glicemiaValue'] != "") {
        await _db.collection(uid).doc('glicemia').collection('c_glicemias').add({
          'data': refeicaoData['selectedDate'],
          'hora': refeicaoData['selectedTime'],
          'timestamp': refeicaoData['selectedDate'],
          'tipo': refeicaoData['selectedMeal'],
          'valor': refeicaoData['glicemiaValue'],
        });
      }

      if (kDebugMode) {
        print('Refeição salva com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar a refeição: $e');
      }
      throw Exception('Erro ao salvar a refeição');
    }
  }

  // Função para salvar uma refeição como favorita no banco de dados
  Future<void> salvarRefeicaoFavorita(
      String nomeFavorito, Map<String, dynamic> refeicaoData) async {
    try {
      refeicaoData['nomeFavorito'] = nomeFavorito;
      await _db
          .collection(uid)
          .doc('favoritos')
          .collection('c_favoritos')
          .add(refeicaoData);
      if (kDebugMode) {
        print('Refeição favorita salva com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar a refeição favorita: $e');
      }
      throw Exception('Erro ao salvar a refeição favorita');
    }
  }

}