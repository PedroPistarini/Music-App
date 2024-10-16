import 'package:flutter/material.dart';
import 'package:flutter_application_1/servivos/autetenficacao_servico.dart';



class Selecaogenerotela extends StatelessWidget {
  const Selecaogenerotela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seleção de Gênero")),
      
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