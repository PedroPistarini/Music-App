import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaylistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para criar uma nova playlist
  Future<void> criarPlaylist(String nomePlaylist) async {
    User? usuario = _auth.currentUser; // Obtendo o usuário autenticado

    if (usuario != null) {
      // Criando a nova playlist no Firestore
      await _firestore
          .collection('playlists')
          .doc(usuario.uid) // Usando o ID do usuário como documento
          .collection('userPlaylists')
          .add({
        'name': nomePlaylist,
        'songs': [], // Inicializa com um array vazio
        'createdAt': Timestamp.now(), // Data de criação
      });
    }
  }

  // Método para obter as playlists do usuário
  Future<List<Map<String, dynamic>>> obterPlaylists() async {
    User? usuario = _auth.currentUser;

    if (usuario != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('playlists')
          .doc(usuario.uid)
          .collection('userPlaylists')
          .get();

      // Transformar os dados em uma lista de mapas
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }
    
    return [];
  }
}
