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
              onTap: () async {
                await AutenticacaoServico().deslogar();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
            Expanded(child: _exibirPlaylists(context)),
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
            final playlistId = playlist.id;

            return ListTile(
              title: Text(playlist['nome']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      _removerPlaylist(playlistId, context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Adicionar música (implementar função)
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playlist removida com sucesso!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
