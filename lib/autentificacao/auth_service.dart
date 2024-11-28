import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> entrarUsuario(
      {required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "O e-mail não está cadastrado.";
        case "wrong-password":
          return "Senha incorreta.";
        default:
          return "Erro ao entrar: ${e.message}";
      }
    }
    return null;
  }

  Future<String?> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
    required String sobrenome,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await userCredential.user!.updateDisplayName(nome);

      await FirebaseFirestore.instance
          .collection(userCredential.user!.uid)
          .doc('dados_pessoais')
          .set({
        'nome': nome,
        'sobrenome': sobrenome,
        'celular': '(xx)xxxxx-xxxx',
        'dataNascimento': 'xx/xx/xxxx',
        'genero': '------',
      });

      await FirebaseFirestore.instance
          .collection(userCredential.user!.uid)
          .doc('dados_medicos')
          .set({
        'tipo': '------',
        'terapia': '------',
        'usaMedicamentos': '------',
        'dataDiagnostico': 'xx/xx/xxxx',
      });

      await FirebaseFirestore.instance
          .collection(userCredential.user!.uid)
          .doc('aceita_termos')
          .set({
        'aceita': false,
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "O e-mail já está em uso.";
        default:
          return "Erro ao cadastrar: ${e.message}";
      }
    }
    return null;
  }

  Future<String?> redefinicaoSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "E-mail não cadastrado.";
      }
      return "Erro ao enviar e-mail de redefinição: ${e.message}";
    }
    return null;
  }

  Future<String?> deslogar(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut(); 
      // Desloga do Google também
    
    } on FirebaseAuthException catch (e) {
      return "Erro ao deslogar: ${e.message}";
    }
    return null;
  }

  Future<String?> removerConta({required String senha}) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: user.email!,
          password: senha,
        );
        await user.delete();
      } else {
        return "Usuário não autenticado.";
      }
    } on FirebaseAuthException catch (e) {
      return "Erro ao remover conta: ${e.message}";
    }
    return null;
  }

  Future<String?> entrarComGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return "Usuário cancelou o login.";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Fazer login no Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Obter o UID do usuário autenticado
      final String uid = userCredential.user!.uid;

      // Verificar e setar os dados de aceite de termos apenas na primeira vez
      final aceitaTermosRef =
          FirebaseFirestore.instance.collection(uid).doc('aceita_termos');
      final aceitaTermosSnapshot = await aceitaTermosRef.get();

      if (!aceitaTermosSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection(uid)
            .doc('dados_pessoais')
            .set({
          'nome': 'nome',
          'sobrenome': 'sobrenome',
          'celular': '(xx)xxxxx-xxxx',
          'dataNascimento': 'xx/xx/xxxx',
          'genero': '------',
        });

        await FirebaseFirestore.instance
            .collection(uid)
            .doc('dados_medicos')
            .set({
          'tipo': '------',
          'terapia': '------',
          'usaMedicamentos': '------',
          'dataDiagnostico': 'xx/xx/xxxx',
        });

        await FirebaseFirestore.instance
            .collection(uid)
            .doc('aceita_termos')
            .set({
          'aceita': false,
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return "Erro de autenticação no Firebase: ${e.message}";
    } catch (e) {
      return "Falha ao entrar com o Google: ${e.toString()}";
    }
  }

  // Função auxiliar para obter o usuário atual
  User? get usuarioAtual => _firebaseAuth.currentUser;
}
