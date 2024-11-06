import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/servivos/tempo_uso_serivco.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TempoUsoServico _tempoUsoServico = TempoUsoServico(); // Instância do serviço de tempo de uso
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Cadastro do usuário.
  Future<String?> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
    required String confirmarsenha,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      await userCredential.user!.updateDisplayName(nome);
      userCredential.user!.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "O usuário já está cadastrado";
      } 
      return "Erro desconhecido: ${e.code}";
    } catch (e) {
      return "Erro inesperado: ${e.toString()}";
    }
  }

  // Login do usuário.
  Future<void> logarUsuario(String email, String senha) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      // Salva o horário de login no Firestore
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).update({
        'loginTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erro ao fazer login: $e');
    }
  }

  // Logout do usuário.
  Future<void> deslogar() async {
    // Para o contador de tempo de uso antes de deslogar
    await _tempoUsoServico.pararContador();
    await _firebaseAuth.signOut();
  }

  // Retorna o ID do usuário autenticado.
  String getUserId() {
    return _firebaseAuth.currentUser?.uid ?? ''; 
  }

  Future<Map<String, dynamic>?> obterDadosUsuario() async {
    User? usuario = _firebaseAuth.currentUser;
    if (usuario != null) {
      DocumentSnapshot snapshot = await _firestore.collection('usuarios').doc(usuario.uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  // Atualizar nome
  Future<void> atualizarNome(String novoNome) async {
    User? usuario = _firebaseAuth.currentUser;
    if (usuario != null) {
      await usuario.updateDisplayName(novoNome);
      await _firestore.collection('usuarios').doc(usuario.uid).update({
        'nome': novoNome,
      });
    }
  }

  // Atualizar e-mail
  Future<void> atualizarEmail(String novoEmail) async {
    User? usuario = _firebaseAuth.currentUser;
    if (usuario != null) {
      await usuario.updateEmail(novoEmail);
      await _firestore.collection('usuarios').doc(usuario.uid).update({
        'email': novoEmail,
      });
    }
  }

  // Redefinir senha
  Future<void> redefinirSenha() async {
    User? usuario = _firebaseAuth.currentUser;
    if (usuario != null && usuario.email != null) {
      await _firebaseAuth.sendPasswordResetEmail(email: usuario.email!);
    }
  }
}
