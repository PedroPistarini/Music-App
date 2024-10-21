import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeneroServico {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Salvar os gêneros selecionados pelo usuário
  Future<void> salvarGeneros(List<String> generos) async {
    final userId = _auth.currentUser?.uid;

    if (userId != null) {
      await _firestore.collection('Gêneros').doc(userId).set({
        'userId': userId,
        'generos': generos,
      }, SetOptions(merge: true)); // Atualiza ou cria o campo 'generos' no documento do usuário
    }
  }

  // Recuperar os gêneros salvos do usuário
  Future<List<String>?> obterGeneros() async {
    final userId = _auth.currentUser?.uid;

    if (userId != null) {
      final docSnapshot = await _firestore.collection('Gêneros').doc(userId).get();
      return List<String>.from(docSnapshot.data()?['generos'] ?? []);
    }
    return null;
  }
}
