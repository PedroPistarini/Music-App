import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/servivos/autetenficacao_servico.dart';

class Playlisttela extends StatelessWidget {
  const Playlisttela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Playlist")),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Deslogar"),
              onTap: () {
                AutenticacaoServico().deslogar();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _criarPlaylist(context),
              child: const Text('Criar Playlist'),
            ),
            Expanded(child: _exibirPlaylists(context)), // Passe o contexto aqui
          ],
        ),
      ),
    );
  }

  void _criarPlaylist(BuildContext context) async {
    final nomePlaylistController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Criar Nova Playlist'),
          content: TextField(
            controller: nomePlaylistController,
            decoration: const InputDecoration(labelText: 'Nome da Playlist'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _salvarPlaylist(nomePlaylistController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _salvarPlaylist(String nomePlaylist) async {
    final firestore = FirebaseFirestore.instance;
    final userId = AutenticacaoServico().getUserId();

    await firestore.collection('playlists').add({
      'nome': nomePlaylist,
      'userId': userId,
      'musicas': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('Playlist "$nomePlaylist" criada com sucesso!');
  }

  StreamBuilder<QuerySnapshot> _exibirPlaylists(BuildContext context) {
    final userId = AutenticacaoServico().getUserId();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final playlists = snapshot.data!.docs;

        return ListView(
          children: playlists.map((playlist) {
            final playlistId = playlist.id; // Obtenha o ID da playlist

            return ListTile(
              title: Text(playlist['nome']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Para não expandir a linha
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      // Chame a função para remover a playlist
                      _removerPlaylist(playlistId, context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Chamada de função para colocar música
                      // Você pode criar uma função para abrir um diálogo para adicionar músicas
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _removerPlaylist(String playlistId, BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('playlists').doc(playlistId).delete();

    // Exibir o SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playlist removida com sucesso!'),
        duration: Duration(seconds: 2), // Duração do SnackBar
        backgroundColor: Colors.green,
      ),
    );
  
    print('Playlist removida com sucesso!');
  }

  
}
