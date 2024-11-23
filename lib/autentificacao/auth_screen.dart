import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:main/autentificacao/auth_service.dart';
import 'package:main/autentificacao/show_snackbar.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();

  bool isEntrando = true;

  final _formKey = GlobalKey<FormState>();

  AuthService authService = AuthService();
  //final FirestoreService _firestoreService = FirestoreService();

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (isEntrando)
                            ? "Bem vindo ao GlicoMetrics!"
                            : "Vamos começar?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      (isEntrando)
                          ? "Faça login."
                          : "Faça seu cadastro para começar.",
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(label: Text("E-mail")),
                      validator: (value) {
                        if (value == null || value == "") {
                          return "O valor de e-mail deve ser preenchido";
                        }
                        if (!value.contains("@") ||
                            !value.contains(".") ||
                            value.length < 4) {
                          return "O valor do e-mail deve ser válido";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(label: Text("Senha")),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return "Insira uma senha válida.";
                        }
                        return null;
                      },
                    ),
                    Visibility(
                      visible: isEntrando,
                      child: TextButton(
                        onPressed: () {
                          esqueciMinhaSenhaClicado();
                        },
                        child: const Text("Esqueci minha senha."),
                      ),
                    ),
                    Visibility(
                        visible: !isEntrando,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _confirmaController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                label: Text("Confirme a senha"),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 4) {
                                  return "Insira uma confirmação de senha válida.";
                                }
                                if (value != _senhaController.text) {
                                  return "As senhas devem ser iguais.";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                label: Text("Nome"),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 3) {
                                  return "Insira um nome maior.";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _sobrenomeController,
                              decoration: const InputDecoration(
                                label: Text("Sobrenome"),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 3) {
                                  return "Insira um nome maior.";
                                }
                                return null;
                              },
                            ),
                          ],
                        )),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        botaoEnviarClicado();
                      },
                      child: Text(
                        (isEntrando) ? "Entrar" : "Cadastrar",
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botão para login com Google
                    SignInButton(
                      Buttons.Google,
                      onPressed: () {
                        _entrarComGoogle();
                      },
                      text: "Entrar com o Google",
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isEntrando = !isEntrando;
                        });
                      },
                      child: Text(
                        (isEntrando)
                            ? "Ainda não tem conta?\nClique aqui para cadastrar."
                            : "Já tem uma conta?\nClique aqui para entrar",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  botaoEnviarClicado() {
    String email = _emailController.text;
    String senha = _senhaController.text;
    String nome = _nomeController.text;
    String sobrenome = _sobrenomeController.text;

    if (_formKey.currentState!.validate()) {
      if (isEntrando) {
        _entrarUsuario(email: email, senha: senha);
      } else {
        _criarUsuario(email: email, senha: senha, nome: nome, sobrenome: sobrenome);
      }
    }
  }

  _entrarUsuario({required String email, required String senha}) {
    authService.entrarUsuario(email: email, senha: senha).then((String? erro) {
      if (erro != null) {
        // ignore: use_build_context_synchronously
        showSnackBar(context: context, mensagem: erro);
      }
    });
  }

  _criarUsuario({
    required String email,
    required String senha,
    required String nome,
    required String sobrenome,
  }) {
    authService.cadastrarUsuario(email: email, senha: senha, nome: nome, sobrenome: sobrenome).then(
      (String? erro) {
        if (erro != null) {
          // ignore: use_build_context_synchronously
          showSnackBar(context: context, mensagem: erro);
        }
      },
    );
  }

  _entrarComGoogle() {
    authService.entrarComGoogle().then((String? erro) {
      if (erro != null) {
        // ignore: use_build_context_synchronously
        showSnackBar(context: context, mensagem: erro);
      }
    });
  }

  esqueciMinhaSenhaClicado() {
    String email = _emailController.text;
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController redefincaoSenhaController =
            TextEditingController(text: email);
        return AlertDialog(
          title: const Text("Confirme o e-mail para redefinição de senha"),
          content: TextFormField(
            controller: redefincaoSenhaController,
            decoration: const InputDecoration(label: Text("Confirme o e-mail")),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32))),
          actions: [
            TextButton(
              onPressed: () {
                authService
                    .redefinicaoSenha(email: redefincaoSenhaController.text)
                    .then((String? erro) {
                  if (erro == null) {
                    showSnackBar(
                      // ignore: use_build_context_synchronously
                      context: context,
                      mensagem: "E-mail de redefinição enviado!",
                      isErro: false,
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    showSnackBar(context: context, mensagem: erro);
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                });
              },
              child: const Text("Redefinir senha"),
            ),
          ],
        );
      },
    );
  }
}
