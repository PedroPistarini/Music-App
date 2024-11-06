import 'package:flutter/material.dart';

import 'package:flutter_application_1/servivos/tempo_uso_serivco.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Perfiltela extends StatefulWidget {
  @override
  _PerfilTelaState createState() => _PerfilTelaState();
}

class _PerfilTelaState extends State<Perfiltela> {

  final TempoUsoServico _tempoUsoServico = TempoUsoServico();

  String _tempoDeUso = "00:00:00";
  String? _nomeUsuario;
  String? _emailUsuario;
  List<String> _conquistas = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _carregarTempoDeUso();
  }

  Future<void> _carregarDadosUsuario() async {
    User? usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      setState(() {
        _nomeUsuario = usuario.displayName ?? "Nome não disponível";
        _emailUsuario = usuario.email ?? "Email não disponível";
      });
    }
  }

  Future<void> _carregarTempoDeUso() async {
    Duration tempoDeUso = await _tempoUsoServico.obterTempoDeUso();
    setState(() {
      _tempoDeUso = _tempoUsoServico.formatarDuracao(tempoDeUso);
    });
    _atualizarConquistas(tempoDeUso);
  }

  void _atualizarConquistas(Duration tempoDeUso) {
    List<String> novasConquistas = [];

    if (tempoDeUso >= Duration(seconds: 15)) {
      novasConquistas.add("🏅 TESTE (15 segundos)");
    }
    if (tempoDeUso >= Duration(hours: 1)) {
      novasConquistas.add("🏅 Iniciante (1 Hora)");
    }
    if (tempoDeUso >= Duration(hours: 10)) {
      novasConquistas.add("🥈 Intermediário (10 Horas)");
    }
    if (tempoDeUso >= Duration(hours: 50)) {
      novasConquistas.add("🥇 Avançado (50 Horas)");
    }
    if (tempoDeUso >= Duration(hours: 100)) {
      novasConquistas.add("🏆 Especialista (100 Horas)");
    }

    setState(() {
      _conquistas = novasConquistas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Caixa para nome e e-mail
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nomeUsuario != null ? "Nome: $_nomeUsuario" : "Carregando nome...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _emailUsuario != null ? "E-mail: $_emailUsuario" : "Carregando e-mail...",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Separador visual para tempo de uso
            Divider(height: 30, thickness: 1.5),

            // Caixa para o tempo de uso do usuário
            Column(
              children: [
                Text(
                  'Tempo de uso acumulado:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  _tempoDeUso,
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _carregarTempoDeUso,
                  child: Text('Atualizar Tempo de Uso'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Separador visual para conquistas
            Divider(height: 30, thickness: 1.5),

            // Conquistas desbloqueadas
            Text(
              'Conquistas Desbloqueadas:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _conquistas.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _conquistas.map((conquista) => Text(conquista, style: TextStyle(fontSize: 16))).toList(),
                    ),
                  )
                : Text(
                    "Nenhuma conquista ainda",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
          ],
        ),
      ),
    );
  }
} 
