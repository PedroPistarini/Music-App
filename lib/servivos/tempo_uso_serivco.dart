import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TempoUsoServico {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;
  int _tempoTotalSegundos = 0;

  // Iniciar o contador ao fazer login
  Future<void> iniciarContador() async {
  var usuario = _auth.currentUser;
  if (usuario == null) return;

  // Verifica se o campo tempoTotal existe para o usuário e inicializa com 0 se não existir
  final userDoc = _firestore.collection('usuarios').doc(usuario.uid);
  final snapshot = await userDoc.get();
  if (!snapshot.exists || !snapshot.data()!.containsKey('tempoTotal')) {
    await userDoc.set({'tempoTotal': 0}, SetOptions(merge: true));
    _tempoTotalSegundos = 0;
  } else {
    _tempoTotalSegundos = snapshot.data()?['tempoTotal'] ?? 0;
  }

  // Inicia o contador que atualiza o tempo total a cada segundo
  _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
    if (_auth.currentUser == null) {
      timer.cancel();
      return;
    }

    _tempoTotalSegundos += 1;
    await userDoc.update({
      'tempoTotal': _tempoTotalSegundos,
    });
  });
}

  // Parar o contador ao fazer logout
  Future<void> pararContador() async {
    _timer?.cancel();
    _timer = null;
  }

  // Obter o tempo total acumulado
  Future<Duration> obterTempoDeUso() async {
    User? usuario = _auth.currentUser;
    if (usuario == null) {
      return Duration.zero;
    }

    try {
      final snapshot = await _firestore.collection('usuarios').doc(usuario.uid).get();
      if (snapshot.exists && snapshot['tempoTotal'] != null) {
        _tempoTotalSegundos = snapshot['tempoTotal'];
        return Duration(seconds: _tempoTotalSegundos);
      }
    } catch (e) {
      print("Erro ao obter tempo de uso: $e");
    }

    return Duration.zero;
  }

  String formatarDuracao(Duration duracao) {
    String horas = duracao.inHours.toString().padLeft(2, '0');
    String minutos = duracao.inMinutes.remainder(60).toString().padLeft(2, '0');
    String segundos = duracao.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$horas:$minutos:$segundos";
  }
}
