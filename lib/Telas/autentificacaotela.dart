import 'package:flutter/material.dart';
import 'package:flutter_application_1/_comum/meu_snakbar.dart';
import 'package:flutter_application_1/_comum/minhascores.dart';
import 'package:flutter_application_1/decora%C3%A7%C3%A3o/decoracao_campo_autenficacao.dart';
import 'package:flutter_application_1/servivos/autetenficacao_servico.dart';

class AutentificacaoTela extends StatefulWidget {
  final VoidCallback onSignup; // Adicione esta linha

  const AutentificacaoTela({super.key, required this.onSignup}); // Adicione o parâmetro aqui

  @override
  State<AutentificacaoTela> createState() => _AutentificacaoTelaState();
}

class _AutentificacaoTelaState extends State<AutentificacaoTela> {

  bool queroEntrar = true;
  String? confirmasenha; 
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  TextEditingController _confirmarsenhaController = TextEditingController();
  TextEditingController _nomeController = TextEditingController();

  AutenticacaoServico _autenServico = AutenticacaoServico();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 223, 223), // Fundo do APP

      body: Stack( // Conseguimos jogar tudo para traz com o STACK 
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ 
                Minhascores.pretoTopoGrandiente, 
                Minhascores.pretoBaixoGradiente,
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(  // Criando uma centralização para a imagem e para o nome
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    
                    //Colocando logo e titúlo do app
                    children: [
                      Image.asset("assets/logomusic.png",height: 128), // Colocando a logo
                      const Text(
                        "MusicApp", // nome do app
                        textAlign: TextAlign.center, // CSS do logo. 
                        style: TextStyle(
                          fontSize: 48, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black
                        ),
                      ),
                
                      // Formulário de e-mail e senha 
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: getAuthenticationInputDecoration("E-mail: "),
                        validator: (String? value) {

                          if(value == null){
                            return " O e-mail não pode ser vazio ";
                          }
                          if(value.length < 5){
                            return " O e-mail é muito curto";
                          }
                          if(!value.contains("@")){
                            return " O e-mail não é valido";
                          }
                    
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _senhaController,
                        decoration: getAuthenticationInputDecoration("Senha: "),
                        obscureText: true,
                        validator: (String? value) {

                          confirmasenha = value;

                          if(value == null){
                            return " A senha não pode ser vazia ";
                          }
                          if(value.length < 5){
                            return " A senha é muito curta";
                          }

                          return null;
                        },
                      ),  
                      const SizedBox(height: 8),
                      
                      // Caso o cliente vai fazer o cadastro troca para essas informações 
                      Visibility(
                        visible: !queroEntrar, 
                        child: Column(
                          children:[
                            TextFormField(

                              controller: _confirmarsenhaController,
                              decoration: getAuthenticationInputDecoration("Confirme a Senha: "),
                              obscureText: true,
                              validator: (String? value) {

                                if(confirmasenha != value){
                                  return " Coloque a mesma senha ";
                                }
                                if(value == null){
                                  return " A confirmação de senha não pode ser vazia ";
                                }
                                if(value.length < 5){
                                  return " A confirmação de senha é muito curta";
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nomeController,
                              decoration: getAuthenticationInputDecoration("Nome: "),
                              validator: (String? value) {
                                if(value == null){
                                  return " O nome não pode ser vazio ";
                                }
                                if(value.length < 2){
                                  return " O nome é muito curto";
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Botão, caso não tenha cadastro ou já tenha conta.
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed:(){
                          botaoPrincipalClicado();    // Validação para ver se quando entrar é válido o e-mail
                        }, 
                        child: Text((queroEntrar)? "Entrar" : "Cadastrar"),
                      ),
                      const Divider(),
                      TextButton(
                        onPressed: (){
                          setState(() {
                            queroEntrar = !queroEntrar;
                          });
                        }, 
                        child: Text((queroEntrar)
                          ? "Ainda não tem uma conta, Cadastre-se!" 
                          : "Já tem uma conta? Entre! " ),
                      ),
                
                    ],
                  ),  
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Verificando se o que o cliente digita é válido! 
 botaoPrincipalClicado() {
  String nome = _nomeController.text;
  String email = _emailController.text;
  String senha = _senhaController.text;
  String confirmarsenha = _confirmarsenhaController.text;

  if (_formKey.currentState!.validate()) {
    if (queroEntrar) {
      // Lógica de login
      print("Entrada Validada");
      _autenServico.logarUsuario(email: email, senha: senha).then(
        (String? erro) {
          if (erro != null) {
            showSnackBar(context: context, texto: erro);
          }
        },
      );
    } else {
      // Lógica de cadastro
      print("Cadastro Validado");
      print("${_emailController.text}, ${_senhaController.text}, ${_nomeController.text}, ${_confirmarsenhaController.text}");
      _autenServico.cadastrarUsuario(email: email, senha: senha, nome: nome, confirmarsenha: confirmarsenha).then(
        (String? erro) {
          if (erro != null) {
            // Voltou com erro
            showSnackBar(context: context, texto: erro);
          } else {
            // Chame o onSignup aqui
            widget.onSignup();
          }
        },
      );
    }
  } else {
    print("Inválido");
  }
  }
}