import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
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
  Future<String?> logarUsuario({required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout do usuário.
  Future<void> deslogar() async {
    await _firebaseAuth.signOut();
  }

  // Retorna o ID do usuário autenticado.
  String getUserId() {
    return _firebaseAuth.currentUser?.uid ?? ''; 
  }
}
