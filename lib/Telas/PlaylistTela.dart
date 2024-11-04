import 'package:flutter/material.dart';
import 'package:flutter_application_1/Telas/detalhesplaylisttela.dart';
import 'package:flutter_application_1/Telas/musicatela.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/servivos/autetenficacao_servico.dart';
import 'package:flutter_application_1/servivos/playlist_servico.dart';

class PlaylistTela extends StatefulWidget {
  const PlaylistTela({Key? key}) : super(key: key);

  @override
  _PlaylistTelaState createState() => _PlaylistTelaState();
}

class _PlaylistTelaState extends State<PlaylistTela> {
  final AutenticacaoServico _authService = AutenticacaoServico();
  final PlaylistService _playlistService = PlaylistService();
  String? topArtista;
  String? topMusica;

  @override
  void initState() {
    super.initState();
    _carregarTopArtistaEMusica();
    _atualizarDailyMix(); // Atualiza o Daily Mix automaticamente ao abrir a tela
  }

  Future<void> _atualizarDailyMix() async {
    await PlaylistService().atualizarDailyMix();
  }


  // Método para carregar o artista e música mais tocados
  Future<void> _carregarTopArtistaEMusica() async {
    final userId = _authService.getUserId();
    if (userId.isEmpty) {
      print("Usuário não autenticado");
      return;
    }

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('playlists')
        .where('userId', isEqualTo: userId)
        .get();

    final Map<String, int> artistasContagem = {};
    final Map<String, int> musicasContagem = {};

    for (var doc in snapshot.docs) {
      final List<dynamic> musicas = doc['songs'] ?? [];

      for (var musica in musicas) {
        final artista = musica['artist'] ?? 'Desconhecido';
        final nomeMusica = musica['name'] ?? 'Sem título';

        artistasContagem[artista] = (artistasContagem[artista] ?? 0) + 1;
        musicasContagem[nomeMusica] = (musicasContagem[nomeMusica] ?? 0) + 1;
      }
    }

    setState(() {
      topArtista = artistasContagem.entries.isNotEmpty
          ? artistasContagem.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null;
      topMusica = musicasContagem.entries.isNotEmpty
          ? musicasContagem.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biblioteca"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await _atualizarDailyMix();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Daily Mix atualizado!')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text("Músicas"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Musicatela()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Deslogar"),
              onTap: () async {
                await _authService.deslogar();
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
            const Divider(),
            _exibirTopArtistaEMusica(),
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
                _playlistService.criarPlaylist(nomePlaylistController.text);
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

  StreamBuilder<QuerySnapshot> _exibirPlaylists(BuildContext context) {
    final userId = _authService.getUserId();

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
            final playlistName = playlist['name'] ?? 'Sem Nome';

            return ListTile(
              title: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetalhesPlaylistTela(
                        playlistId: playlistId,
                        playlistName: playlistName,
                      ),
                    ),
                  );
                },
                child: Text(playlistName),
              ),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Musicatela(),
                        ),
                      );
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

  Widget _exibirTopArtistaEMusica() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Seus Tops",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (topArtista != null)
            _carrosselItem("Top Artista", topArtista!),
          if (topMusica != null)
            _carrosselItem("Top Música", topMusica!),
        ],
      ),
    );
  }

  Widget _carrosselItem(String titulo, String valor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              valor,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removerPlaylist(String playlistId, BuildContext context) async {
    await _playlistService.removerPlaylist(playlistId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playlist removida com sucesso!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}