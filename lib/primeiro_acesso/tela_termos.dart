import 'package:flutter/material.dart';
import 'package:main/firebase/firestore_service.dart';
import 'package:main/main.dart';

class TelaTermosPrivacidade extends StatelessWidget {
  final String nome;
  final String sobrenome;
  final String celular;
  final String nascimento;
  final String genero;
  final String tipo;
  final String terapia;
  final String usaMedicamentos;
  final String diagnostico;
  final double peso;
  final int altura;

  TelaTermosPrivacidade(
      {super.key,
      required this.nome,
      required this.sobrenome,
      required this.celular,
      required this.nascimento,
      required this.genero,
      required this.tipo,
      required this.terapia,
      required this.usaMedicamentos,
      required this.diagnostico,
      required this.peso,
      required this.altura});

  final FirestoreService firebaseService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Termos e Privacidade"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Termos de Uso do Glicometrics",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Última atualização: 21 de novembro de 2024",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("1. Sobre o Glicometrics"),
            _buildParagraph(
              "O Glicometrics é uma ferramenta em versão Beta de testes, desenvolvida para ser um suporte no acompanhamento da sua saúde. Atualmente, suas principais funcionalidades incluem:\n"
              "- Monitoramento de glicose, pressão arterial e IMC.\n"
              "- Sugestão de receitas personalizadas baseadas em inteligência artificial.\n"
              "- Suporte para registro de alimentação e dados de saúde.\n\n"
              "É importante ressaltar que o Glicometrics não substitui orientações médicas, diagnósticos ou tratamentos profissionais. Recomendamos que todas as decisões relacionadas à sua saúde sejam realizadas com o acompanhamento de um profissional qualificado.",
            ),
            _buildSectionTitle(
                "2. Uso das Receitas Geradas por Inteligência Artificial"),
            _buildParagraph(
              "As receitas sugeridas pelo Glicometrics são geradas automaticamente com base em informações da própria inteligência artificial; isso inclui que, não levamos em considerações nenhum tipo de alergia ou contraindicação (a não ser a diabetes) para a geração de receita. Apesar de nosso compromisso em fornecer informações úteis e relevantes, é fundamental considerar os seguintes pontos:\n\n"
              "1. Responsabilidade do Usuário: O usuário é o único responsável por avaliar a adequação das receitas às suas condições de saúde e restrições alimentares.\n"
              "2. Limitações do Aplicativo:\n"
              "- As sugestões são baseadas em informações gerais e não levam em conta variáveis específicas de saúde que não tenham sido fornecidas pelo usuário na geração da resposta da receita.\n"
              "- O Glicometrics não foi projetado para gerenciar emergências médicas ou substituir aconselhamentos profissionais.\n"
              "3. Danos e Riscos: Não nos responsabilizamos por quaisquer danos físicos, alergias ou complicações resultantes do uso das receitas sugeridas. É responsabilidade do usuário verificar ingredientes, métodos de preparo e sua compatibilidade com suas necessidades de saúde.",
            ),
            _buildSectionTitle("3. Versão Beta e Possíveis Alterações"),
            _buildParagraph(
              "Por estar em versão Beta, o Glicometrics ainda está em fase de desenvolvimento e melhorias. Isso significa que:\n"
              "- Algumas funcionalidades podem apresentar inconsistências ou comportamentos inesperados.\n"
              "- Recursos e telas podem sofrer alterações significativas ao longo do tempo, com o objetivo de aprimorar a experiência do usuário.\n\n"
              "Apesar disso, garantimos nosso compromisso em entregar sempre o melhor que temos a oferecer, buscando constante inovação e melhorias com base no feedback dos usuários.",
            ),
            _buildSectionTitle("4. Política de Privacidade"),
            _buildParagraph(
              "A proteção de seus dados é uma prioridade para nós. Recomendamos que leia nossa Política de Privacidade abaixo para entender como coletamos, usamos e protegemos as informações fornecidas por você.\n\n"
              "Última atualização: 21 de novembro de 2024\n\n"
              "No Glicometrics, valorizamos a sua privacidade e nos comprometemos com a segurança e confidencialidade de suas informações. Este documento descreve como coletamos, usamos, armazenamos e protegemos os dados fornecidos pelos usuários. Ao utilizar nosso aplicativo, você concorda com os termos desta Política de Privacidade. Caso não concorde, recomendamos que não utilize o aplicativo.",
            ),
            _buildSectionTitle("5. Limitação de Responsabilidade"),
            _buildParagraph(
              "O Glicometrics é fornecido \"como está\", sem garantias de qualquer tipo, explícitas ou implícitas. Não garantimos que:\n"
              "- O aplicativo atenderá todas as suas expectativas ou necessidades.\n"
              "- Os resultados ou informações fornecidos serão 100% precisos ou livres de erros.\n"
              "- O serviço estará disponível de forma ininterrupta ou livre de falhas.\n\n"
              "Ao utilizar o Glicometrics, você concorda em isentar os desenvolvedores e responsáveis pelo aplicativo de qualquer responsabilidade por danos diretos, indiretos, incidentais, ou consequentes relacionados ao uso do software.",
            ),
            _buildSectionTitle("6. Alterações nos Termos de Uso"),
            _buildParagraph(
              "Reservamo-nos o direito de atualizar estes Termos de Uso a qualquer momento. Caso isso ocorra, notificaremos os usuários por meio do aplicativo ou por outros canais de comunicação disponíveis. Recomendamos que revise este documento periodicamente para se manter atualizado.",
            ),
            _buildSectionTitle("7. Contato"),
            _buildParagraph(
              "Se tiver dúvidas ou preocupações sobre nossa Política de Privacidade ou sobre como tratamos suas informações, entre em contato conosco por:\n\n"
              "E-mail: glicometrics@gmail.com",
            ),
            _buildSectionTitle(
                "Ao continuar, você aceita os Termos e a Política de Privacidade do Glicometrics."),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await firebaseService.salvarDadosPessoais(
                  nome: nome,
                  sobrenome: sobrenome,
                  celular: celular,
                  dataNascimento: nascimento,
                  genero: genero,
                );
                await firebaseService.salvarDadosMedicos(
                  tipo: tipo,
                  terapia: terapia,
                  usaMedicamentos: usaMedicamentos,
                  dataDiagnostico: diagnostico,
                );
                await firebaseService.salvarAltura(altura: altura);
                await firebaseService.salvarPeso(peso: peso);
                await firebaseService.setAceitaTermos(true);

                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (route) => false,
                );
              },
              child: const Text("Aceitar e Concluir"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
