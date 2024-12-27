import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  // Autenticando o usuário atual
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Função para buscar o último registro de pressão arterial
  Future<Map<String, dynamic>?> getDadosPessoais() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot =
          await _db.collection(uid).doc('dados_pessoais').get();

      return querySnapshot.data();
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar último registro de pressão: $e");
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> setAceitaTermos(bool aceita) async {
    try {
      await _db.collection(uid).doc('aceita_termos').update({
        'aceita': aceita,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar: $e");
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getAceitaTermos() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot =
          await _db.collection(uid).doc('aceita_termos').get();

      if (querySnapshot.exists) {
        final data = querySnapshot.data();
        if (kDebugMode) {
          print("Dados do Firestore: $data");
        } // Log dos dados
        return data;
      } else {
        if (kDebugMode) {
          print("Documento 'aceita_termos' não encontrado para UID: $uid");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar último registro de pressão: $e");
      }
    }
    return null;
  }

  // Função para salvar o peso atual
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

  // Função para salvar dados de pressão arterial
  Future<void> salvarDadosMedicos({
    required String tipo,
    required String terapia,
    required String usaMedicamentos,
    required String dataDiagnostico,
  }) async {
    try {
      await _db.collection(uid).doc('dados_medicos').update({
        'tipo': tipo,
        'terapia': terapia,
        'usaMedicamentos': usaMedicamentos,
        'dataDiagnostico': dataDiagnostico,
      });
      if (kDebugMode) {
        print('Dados salvos com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar dados: $e');
      }
    }
  }

  Future<void> salvarDadosPessoais({
    required String nome,
    required String sobrenome,
    required String celular,
    required String dataNascimento,
    required String genero,
  }) async {
    try {
      await _db.collection(uid).doc('dados_pessoais').update({
        'nome': nome,
        'sobrenome': sobrenome,
        'celular': celular,
        'dataNascimento': dataNascimento,
        'genero': genero,
      });
      if (kDebugMode) {
        print('Dados salvos com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar dados: $e');
      }
    }
  }

}
