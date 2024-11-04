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

        // Garante que cada música tenha playCount definido como 0, se não existir
        final List<dynamic> songs = (data['songs'] as List<dynamic>?)?.map((song) {
          return {
            'id': song['id'],
            'name': song['name'],
            'artist': song['artist'],
            'playCount': song['playCount'] ?? 0, // Define playCount como 0 se não existir
            'imageUrl': song['imageUrl'],
          };
        }).toList() ?? [];

        return {
          'id': doc.id,
          'name': data['name'] ?? 'Sem Nome',
          'songs': songs,
        };
      }).toList();
    }

    return [];
  }

  // Método para adicionar uma música à playlist específica
  Future<void> adicionarMusicaAPlaylist(String playlistId, Map<String, dynamic> musica) async {
    DocumentReference playlistRef = _firestore.collection('playlists').doc(playlistId);

    // Inicializar playCount como zero se não estiver presente
    musica['playCount'] = musica.containsKey('playCount') ? musica['playCount'] : 0;

    await playlistRef.update({
      'songs': FieldValue.arrayUnion([musica]),
    });
  }

  // Método para remover uma playlist
  Future<void> removerPlaylist(String playlistId) async {
    await _firestore.collection('playlists').doc(playlistId).delete();
  }

  // Incrementa o playCount de uma música específica na coleção 'plays'
  Future<void> incrementarPlayCount(String songId, Map<String, dynamic> songData) async {
    DocumentReference playRef = _firestore.collection('plays').doc(songId);

    // Atualiza o playCount na coleção 'plays' usando FieldValue.increment
    await playRef.set({
      'songData': songData,
      'playCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    print("Play count incrementado para ${songData['name']}");
  }

  // Método para atualizar a playlist "Daily Mix"
  Future<void> atualizarDailyMix() async {
    User? usuario = _auth.currentUser;
    if (usuario == null) return;

    // Verificar se a playlist "Daily Mix" já existe
    QuerySnapshot querySnapshot = await _firestore
        .collection('playlists')
        .where('userId', isEqualTo: usuario.uid)
        .where('name', isEqualTo: 'Daily Mix')
        .get();

    String dailyMixId;
    if (querySnapshot.docs.isEmpty) {
      // Criar "Daily Mix" se não existir
      DocumentReference docRef = await _firestore.collection('playlists').add({
        'name': 'Daily Mix',
        'userId': usuario.uid,
        'songs': [],
        'createdAt': Timestamp.now(),
      });
      dailyMixId = docRef.id;
    } else {
      // Obter o ID da "Daily Mix" existente
      dailyMixId = querySnapshot.docs.first.id;
    }

    // Buscar as músicas mais populares na coleção 'plays'
    QuerySnapshot playSnapshot = await _firestore
        .collection('plays')
        .orderBy('playCount', descending: true)
        .limit(10)
        .get();

        List<Map<String, dynamic>> topMusicas = playSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': data['songData']['id'],
        'name': data['songData']['name'],
        'artist': data['songData']['artist'],
        'playCount': data['playCount'] ?? 0,
        'imageUrl': data['songData']['imageUrl'],
      };
    }).toList();

    // Atualizar a playlist "Daily Mix" com as músicas mais populares
    await _firestore.collection('playlists').doc(dailyMixId).update({
      'songs': topMusicas,
    });

    print("Playlist 'Daily Mix' atualizada com as músicas mais populares.");
  }
}

