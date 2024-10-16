import 'package:flutter/material.dart';
import 'package:flutter_application_1/servivos/autetenficacao_servico.dart';


class InicioTela extends StatelessWidget {
  const InicioTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tela Inicial")),
      
      // Barra superior esquerdo para deslogar
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text("Deslogar"),
              onTap: (){
                AutenticacaoServico().deslogar();
              },
            ),
          ],
        ),
      ),
    );
  }
}