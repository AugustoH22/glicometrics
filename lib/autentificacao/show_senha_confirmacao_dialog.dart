import 'package:flutter/material.dart';
import 'package:main/autentificacao/auth_service.dart';


showSenhaConfirmacaoDialog({
  required BuildContext context,
  required String email,
}) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController senhaConfirmacaoController =
          TextEditingController();
      return AlertDialog(
        title: Text("Deseja remover a conta com o e-mail $email?"),
        content: SizedBox(
          height: 175,
          child: Column(
            children: [
              const Text(
                  "Para confirmar a remoção da conta, insira sua senha:"),
              TextFormField(
                controller: senhaConfirmacaoController,
                obscureText: true,
                decoration: const InputDecoration(label: Text("Senha")),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AuthService()
                  .removerConta(senha: senhaConfirmacaoController.text)
                  .then((String? erro) {
                if (erro == null) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              });
            },
            child: const Text("EXCLUIR CONTA"),
          )
        ],
      );
    },
  );
}
