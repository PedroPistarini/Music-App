import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServico {

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
      
      return null;
    } 
    on FirebaseAuthException catch (e) {  
      if (e.code == "email-already-in-use") {
        return "O usuário já está cadastrado";
      } 
      return "Erro desconhecido: ${e.code}";
    } catch (e) {
      return "Erro inesperado: ${e.toString()}";
    }
  }

  // Login do usuário.
  Future<String?> LogarUsuario(
    {required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> deslogar(){
    return _firebaseAuth.signOut();
  }

  String getUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? ''; // Retorna o ID do usuário autenticado
  }
}
