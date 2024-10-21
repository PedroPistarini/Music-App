// lib/telas/selecao_genero_tela.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Telas/PlaylistTela.dart';
import 'package:flutter_application_1/servivos/autetenficacao_servico.dart';
import 'package:flutter_application_1/servivos/genero_servico.dart';


class SelecaoGeneroTela extends StatefulWidget {
  const SelecaoGeneroTela({super.key});

  @override
  _SelecaoGeneroTelaState createState() => _SelecaoGeneroTelaState();
}

class _SelecaoGeneroTelaState extends State<SelecaoGeneroTela> {
  final List<String> _generosSelecionados = [];

  final List<Map<String, String>> _generos = [
    {'nome': 'Rock', 'imagem': 'assets/images/rock.png'},
    {'nome': 'Pop', 'imagem': 'assets/images/pop.png'},
    {'nome': 'Jazz', 'imagem': 'assets/images/jazz.png'},
    {'nome': 'Hip-Hop', 'imagem': 'assets/images/hiphop.png'},
    {'nome': 'Clássico', 'imagem': 'assets/images/classico.png'},
    {'nome': 'Eletrônica', 'imagem': 'assets/images/eletronica.png'},
    {'nome': 'Sertanejo', 'imagem': 'assets/images/sertanejo.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleção de Gênero'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Deslogar"),
              onTap: () {
                AutenticacaoServico().deslogar();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: _generos.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_generosSelecionados.contains(_generos[index]['nome'])) {
                      _generosSelecionados.remove(_generos[index]['nome']);
                    } else {
                      if (_generosSelecionados.length < 3) {
                        _generosSelecionados.add(_generos[index]['nome']!);
                      }
                    }
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _generos[index]['imagem']!,
                      height: 40,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _generos[index]['nome']!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Checkbox(
                      value: _generosSelecionados.contains(_generos[index]['nome']),
                      onChanged: (bool? isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            if (_generosSelecionados.length < 3) {
                              _generosSelecionados.add(_generos[index]['nome']!);
                            }
                          } else {
                            _generosSelecionados.remove(_generos[index]['nome']);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: _generosSelecionados.isEmpty ? null : () => _salvarGeneros(),
          child: const Text('Confirmar Seleção'),
        ),
      ),
    );
  }

  Future<void> _salvarGeneros() async {
    if (_generosSelecionados.isNotEmpty) {
      await GeneroServico().salvarGeneros(_generosSelecionados);

      // Exibir um SnackBar para confirmar que os gêneros foram salvos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gêneros ${_generosSelecionados.join(", ")} salvos com sucesso!'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Mostrar popup para redirecionar para a tela de playlist
      _mostrarPopupRedirecionar();
    }
  }

  void _mostrarPopupRedirecionar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Redirecionar'),
          content: const Text('Deseja ir diretamente para a tela de playlist?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o popup
              },
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o popup
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Playlisttela()), // Direto para a PlaylistTela
                );
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }
}
