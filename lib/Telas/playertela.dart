import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlayerTela extends StatefulWidget {
  final List<dynamic> playlist;
  final int initialIndex;

  const PlayerTela({Key? key, required this.playlist, required this.initialIndex}) : super(key: key);

  @override
  _PlayerTelaState createState() => _PlayerTelaState();
}

class _PlayerTelaState extends State<PlayerTela> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _nextSong() {
    if (_currentIndex < widget.playlist.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousSong() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  // Incrementa o playCount na coleção 'plays' para a música atual
  Future<void> _incrementPlayCount() async {
    final currentSong = widget.playlist[_currentIndex];
    final String songId = currentSong['id'];

    try {
      // Referência para a música na coleção 'plays'
      DocumentReference playRef = FirebaseFirestore.instance.collection('plays').doc(songId);

      // Atualiza o playCount usando FieldValue.increment
      await playRef.set({
        'songData': currentSong,
        'playCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
      
      print("Play count incrementado para ${currentSong['name']}");

    } catch (error) {
      print("Erro ao incrementar playCount: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.playlist[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSong['name'] ?? 'Música'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exibe a capa da música
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
                image: currentSong['imageUrl'] != null
                    ? DecorationImage(
                        image: NetworkImage(currentSong['imageUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            // Nome e Artista da música
            Text(
              currentSong['name'] ?? 'Nome da música',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              currentSong['artist'] ?? 'Artista',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Barra de Progresso (estática para fins visuais)
            Slider(
              min: 0,
              max: 100,
              value: 50, // Valor fixo apenas para exibição visual
              onChanged: (value) {},
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("0:00"),
                Text("3:45"), // Duração fixa para exibição visual
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 36,
                  onPressed: _previousSong,
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: 48,
                  onPressed: () async {
                    await _incrementPlayCount();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 36,
                  onPressed: _nextSong,
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}