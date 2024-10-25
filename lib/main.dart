import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Telas/PlaylistTela.dart';
import 'package:flutter_application_1/Telas/autentificacaotela.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/Telas/selecaogenerotela.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// Variável global para identificar se o usuário acabou de se cadastrar
bool isSignup = false;

// Chamada da tela inicial ( autentificador )
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RoteadorTela(),
      routes: {
        '/playlist': (context) => const Playlisttela(),
        '/selecaogenero': (context) => const SelecaoGeneroTela(),
      },
    );
  }
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Verifica se o usuário acabou de se cadastrar
          if (isSignup) {
            isSignup = false; // Resetando a flag
            return const SelecaoGeneroTela(); // Redireciona para a tela de gênero                   // Lembrar de alterar, por que tem algum problema nessa parte de troca de telas.
          } else {
            return const Playlisttela(); // Redireciona para a tela da playlist
          }
        } else {
          return AutentificacaoTela(
            onSignup: () {
              // Callback que será chamada quando o usuário se cadastrar
              isSignup = true;
            },
          );
        }
      },
    );
  }
}
