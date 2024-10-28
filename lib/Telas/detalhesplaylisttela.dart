import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Telas/playertela.dart';

class DetalhesPlaylistTela extends StatelessWidget {
  final String playlistId;
  final String playlistName;

  const DetalhesPlaylistTela({Key? key, required this.playlistId, required this.playlistName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playlist: $playlistName"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('playlists').doc(playlistId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final playlistData = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> songs = playlistData['songs'] ?? [];

          if (songs.isEmpty) {
            return const Center(child: Text("Nenhuma música nesta playlist."));
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: song['imageUrl'] != null
                    ? Image.network(song['imageUrl'], width: 50, height: 50)
                    : Container(width: 50, height: 50, color: Colors.grey), // Exibe a capa da música
                title: Text(song['name'] ?? 'Nome da música não disponível'),
                subtitle: Text(song['artist'] ?? 'Artista não disponível'),
                onTap: () {
                  // Ao clicar na música, abre o player passando a playlist e o índice da música
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlayerTela(
                        playlist: songs,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
