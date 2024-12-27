import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  // Autenticando o usuário atual
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Future<List<Map<String, dynamic>>> getTotalNutricaoPorPeriodo(
      DateTime startDate) async {
    List<Map<String, dynamic>> nutrientesPorDia = [];

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startDate.subtract(Duration(days: i));
      Map<String, double> nutrientesDia =
          await getTotalNutricaoDoDia(currentDate);
      nutrientesPorDia.add({'data': currentDate, ...nutrientesDia});
    }

    return nutrientesPorDia;
  }

  Future<Map<String, double>> getTotalNutricaoDoDia(DateTime data) async {
    try {
      double totalCalorias = 0;
      double totalCarboidratos = 0;
      double totalProteinas = 0;
      double totalGorduras = 0;

      QuerySnapshot refeicoesSnapshot = await _db
          .collection(uid)
          .doc('refeicoes')
          .collection('c_refeicoes')
          .where('selectedDate', isGreaterThanOrEqualTo: data)
          .where('selectedDate', isLessThan: data.add(const Duration(days: 1)))
          .get();

      for (var doc in refeicoesSnapshot.docs) {
        totalCalorias += double.tryParse(doc['totalCalorias'].toString()) ?? 0;
        totalCarboidratos +=
            double.tryParse(doc['totalCarboidratos'].toString()) ?? 0;
        totalProteinas +=
            double.tryParse(doc['totalProteinas'].toString()) ?? 0;
        totalGorduras += double.tryParse(doc['totalGorduras'].toString()) ?? 0;
      }

      return {
        'calorias': totalCalorias,
        'carboidratos': totalCarboidratos,
        'proteinas': totalProteinas,
        'gorduras': totalGorduras,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar dados nutricionais: $e');
      }
      return {
        'calorias': 0,
        'carboidratos': 0,
        'proteinas': 0,
        'gorduras': 0,
      };
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


// Função para buscar as medições de glicemia dos últimos 30 dias
  Future<List<Map<String, dynamic>>> fetchGlicemiaUltimos30Dias() async {
    final DateTime dataLimite =
        DateTime.now().subtract(const Duration(days: 30));

    try {
      QuerySnapshot snapshot = await _db
          .collection(uid) // Confirma o uso do UID do usuário
          .doc('glicemia')
          .collection('c_glicemias')
          .where('data', isGreaterThanOrEqualTo: dataLimite)
          .orderBy('data')
          .get();

      if (snapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('Nenhum documento de glicemia encontrado no Firestore.');
        }
      }

      return snapshot.docs.map((doc) {
        DateTime data = (doc['data'] as Timestamp).toDate();
        double valorGlicemia = double.tryParse(doc['valor'].toString()) ?? 0.0;

        if (kDebugMode) {
          print('Data: $data, Valor: $valorGlicemia');
        } // Log dos dados recuperados
        return {
          'data': data,
          'valor': valorGlicemia,
        };
      }).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao buscar medições de glicemia: $error');
      }
      return [];
    }
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

  // Função para Buscar as Refeições do Dia
  Future<List<Map<String, dynamic>>> getRefeicoesDoDia() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(uid)
          .doc('refeicoes')
          .collection('c_refeicoes')
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar refeições do dia: $e");
      }
      return [];
    }
  }
}
