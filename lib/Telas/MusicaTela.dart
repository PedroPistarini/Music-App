import 'package:flutter/material.dart';
import 'package:flutter_application_1/servivos/autetenficacao_servico.dart';
import 'package:flutter_application_1/servivos/playlist_servico.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Musicatela extends StatefulWidget {
  const Musicatela({Key? key}) : super(key: key);

  @override
  _MusicatelaState createState() => _MusicatelaState();
}

class _MusicatelaState extends State<Musicatela> {
  final String clientId = '301c405d749746f38425c7de4a1e45af';
  final String clientSecret = '70cc0a31581e47b6a3a3700879aa4ca5';
  final AutenticacaoServico _authService = AutenticacaoServico();
  final PlaylistService _playlistService = PlaylistService();

  String? _accessToken;
  List<dynamic> musicas = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _obterToken();
  }

  Future<void> _obterToken() async {
    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _accessToken = data['access_token'];
      });
      _buscarRecomendacoes(); // Busca recomendações ao obter o token
    } else {
      throw Exception('Falha ao obter token');
    }
  }

  Future<void> _buscarRecomendacoes() async {
    if (_accessToken == null) return;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/browse/new-releases?limit=10'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        musicas = data['albums']['items']; // Armazena as recomendações
      });
    } else {
      throw Exception('Falha ao carregar recomendações');
    }
  }

  Future<void> buscarMusicas() async {
    if (_accessToken == null) {
      throw Exception('Token de acesso não disponível');
    }

    final termo = _controller.text;
    if (termo.isEmpty) return;

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$termo&type=track&limit=10'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        musicas = data['tracks']['items'];
      });
    } else {
      throw Exception('Falha ao carregar músicas');
    }
  }

  Future<void> adicionarMusicaAPlaylist(dynamic musica) async {
    final userId = _authService.getUserId();
    if (userId.isEmpty) {
      print("Usuário não autenticado");
      return;
    }

    List<Map<String, dynamic>> playlists = await _playlistService.obterPlaylists();

    if (playlists.isEmpty) {
      print("Nenhuma playlist encontrada.");
      return;
    }

    String? selectedPlaylistId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Escolha uma Playlist'),
              content: SingleChildScrollView(
                child: Column(
                  children: playlists.map((playlist) {
                    final playlistId = playlist['id'];
                    final playlistName = playlist['name'] ?? 'Sem Nome';

                    return RadioListTile<String>(
                      title: Text(playlistName),
                      value: playlistId,
                      groupValue: selectedPlaylistId,
                      onChanged: (value) {
                        setState(() {
                          selectedPlaylistId = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (selectedPlaylistId != null && selectedPlaylistId!.isNotEmpty) {
                      await _playlistService.adicionarMusicaAPlaylist(selectedPlaylistId!, {
                        'name': musica['name'],
                        'artist': musica['artists'][0]['name'],
                        'id': musica['id'],
                        'imageUrl': musica['album']['images'][0]['url'] // Armazena a capa da música
                      });
                      Navigator.of(context).pop();
                    } else {
                      print("Nenhuma playlist selecionada.");
                    }
                  },
                  child: const Text('Adicionar'),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Músicas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.deslogar();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Buscar Música',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: buscarMusicas,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: musicas.length,
              itemBuilder: (context, index) {
                final musica = musicas[index];
                final imageUrl = musica['images'] != null ? musica['images'][0]['url'] : null;
                return ListTile(
                  leading: imageUrl != null
                      ? Image.network(imageUrl, width: 50, height: 50)
                      : Container(width: 50, height: 50, color: Colors.grey), // Exibe a capa ou um placeholder
                  title: Text(musica['name']),
                  subtitle: Text(musica['artists'][0]['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => adicionarMusicaAPlaylist(musica),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
