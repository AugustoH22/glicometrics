import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        'hora': '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
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

  // Função para salvar dados de pressão arterial
  Future<void> salvarDadosMedicos({
    required String tipo,
    required String terapia,
    required String usaMedicamentos,
    required String dataDiagnostico,

  }) async {
    try {
      await _db
          .collection(uid)
          .doc('dados_medicos')
          .update({
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
      await _db
          .collection(uid)
          .doc('dados_pessoais')
          .update({
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

  // Função para buscar o último registro de pressão arterial
  Future<Map<String, dynamic>?> getDadosPessoais() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection(uid)
          .doc('dados_pessoais')
          .get();

      return querySnapshot.data();
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar último registro de pressão: $e");
      }
    }
    return null;
  }

  // Função para buscar o último registro de pressão arterial
  Future<Map<String, dynamic>?> getDadosMedicos() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection(uid)
          .doc('dados_medicos')
          .get();

      if (querySnapshot.exists) {
        return querySnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar último registro de pressão: $e");
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> setAceitaTermos(bool aceita) async {
    try {
      await _db
          .collection(uid)
          .doc('aceita_termos')
          .update({
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
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection(uid)
          .doc('aceita_termos')
          .get();

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

  // Função para salvar a glicemia
  Future<void> salvarGlicemia({
    required DateTime data,
    required TimeOfDay hora,
    required String tipo,
    required String valorGlicemia,
  }) async {
    try {
      final glicemiaData = {
        'data': data,
        'hora':
            '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
        'tipo': tipo,
        'valor': double.tryParse(valorGlicemia) ?? 0.0,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _db
          .collection(uid)
          .doc('glicemia')
          .collection('c_glicemias')
          .add(glicemiaData);

      if (kDebugMode) {
        print('Glicemia salva com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar glicemia: $e');
      }
    }
  }

  // Função para Buscar Medições de Glicemia
  Future<List<Map<String, dynamic>>> getMedicoesGlicemia() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(uid)
          .doc('glicemia')
          .collection('c_glicemias')
          .orderBy('data', descending: true)
          .get();

      // Converte os dados para uma lista de Map<String, dynamic>
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Erro ao buscar medições de glicemia: $error');
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

  // Função para buscar o histórico de registros de glicemia, pressão e peso
  Future<List<Map<String, dynamic>>> getHistoricoRegistros() async {
    try {
      List<Map<String, dynamic>> historico = [];

      // Buscar histórico de glicemia
      QuerySnapshot glicemiaSnapshot = await _db
          .collection(uid)
          .doc('glicemia')
          .collection('c_glicemia')
          .orderBy('data', descending: true)
          .get();
      for (var doc in glicemiaSnapshot.docs) {
        historico.add({
          'tipo': 'Glicemia',
          'data': (doc['data'] as Timestamp).toDate(),
          'valor': doc['valor'],
          'hora': doc['hora'],
        });
      }

      // Buscar histórico de pressão arterial
      QuerySnapshot pressaoSnapshot = await _db
          .collection(uid)
          .doc('pressao_arterial')
          .collection('c_pressao_arterial')
          .orderBy('data', descending: true)
          .get();
      for (var doc in pressaoSnapshot.docs) {
        historico.add({
          'tipo': 'Pressão Arterial',
          'data': (doc['data'] as Timestamp).toDate(),
          'sistolica': doc['sistolica'],
          'diastolica': doc['diastolica'],
          'hora': doc['hora'],
        });
      }

      // Buscar histórico de peso
      QuerySnapshot pesoSnapshot = await _db
          .collection(uid)
          .doc('peso')
          .collection('c_peso')
          .orderBy('data', descending: true)
          .get();
      for (var doc in pesoSnapshot.docs) {
        historico.add({
          'tipo': 'Peso',
          'data': (doc['data'] as Timestamp).toDate(),
          'peso': doc['peso'],
          'hora': doc['hora'],
        });
      }

      // Ordenar o histórico pela data
      historico.sort((a, b) => (b['data'] as DateTime).compareTo(a['data']));

      return historico;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar histórico de registros: $e');
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
