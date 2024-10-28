import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaylistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para criar uma nova playlist
  Future<void> criarPlaylist(String nomePlaylist) async {
    User? usuario = _auth.currentUser;

    if (usuario != null) {
      await _firestore.collection('playlists').add({
        'name': nomePlaylist,
        'userId': usuario.uid,
        'songs': [],
        'createdAt': Timestamp.now(),
      });
    }
  }

  // Método para obter as playlists do usuário
  Future<List<Map<String, dynamic>>> obterPlaylists() async {
    User? usuario = _auth.currentUser;

    if (usuario != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('playlists')
          .where('userId', isEqualTo: usuario.uid)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Sem Nome',
          'songs': data['songs'] ?? []
        };
      }).toList();
    }

    return [];
  }

  // Método para adicionar uma música à playlist específica
  Future<void> adicionarMusicaAPlaylist(String playlistId, Map<String, dynamic> musica) async {
    User? usuario = _auth.currentUser;

    if (usuario != null) {
      DocumentReference playlistRef = _firestore.collection('playlists').doc(playlistId);

      await playlistRef.update({
        'songs': FieldValue.arrayUnion([musica]),
      });
    }
  }

  // Método para remover uma playlist
  Future<void> removerPlaylist(String playlistId) async {
    await _firestore.collection('playlists').doc(playlistId).delete();
  }
}
