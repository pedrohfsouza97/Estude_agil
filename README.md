# Estude Ágil

Aplicativo móvel de apoio à preparação para certificações em **Scrum** e **gestão de projetos**, desenvolvido em **Dart/Flutter** com banco de dados local **SQLite**.

> Aplicativo independente de apoio ao estudo. **Não emite certificação oficial** e não garante aprovação nos exames.

## Integrantes

| Nome | RA |
|------|----|
| Pedro Henrique Ferreira de Souza | 2025102875 |
| Igor Viana Gomes da Silva | 2025113276 |

**Curso:** Análise e Desenvolvimento de Software · **Período:** Noturno · **Turma:** B

## Problema e proposta

O estudante que se prepara para uma certificação costuma ter dificuldade de acompanhar o que já estudou e de identificar quais conteúdos precisam de revisão. O Estude Ágil organiza o estudo em etapas, com resumo do conteúdo, quiz com gabarito explicativo e registro do progresso. O nome permite ampliar as trilhas além do Scrum.

**Valores:** clareza, autonomia, acessibilidade e melhoria contínua.

## Funcionalidades

- Cadastro e login com nome, e-mail e senha (a senha é guardada com hash SHA-256 e um valor aleatório "sal", nunca em texto puro).
- Três trilhas, nove etapas e 54 perguntas:
  - **PSM I** (Professional Scrum Master I): fundamentos de Scrum, Scrum Team, eventos e artefatos.
  - **PSPO** (Professional Scrum Product Owner): papel do Product Owner, Product Backlog e Product Goal, Sprint Review e stakeholders.
  - **PMP** (Project Management Professional): fundamentos de projetos, abordagens preditiva, ágil e híbrida, riscos e partes interessadas.
- Cada etapa tem um banco de seis perguntas. A cada tentativa o quiz sorteia três, com as alternativas embaralhadas.
- Resumo de cada etapa com confirmação de leitura.
- Gabarito ao final de cada quiz, com a explicação de cada questão.
- Visualizador do **Guia do Scrum 2020** em português (16 páginas) dentro do app, com indicação das páginas para reler quando o aluno erra.
- Perfil com etapas concluídas, percentual de acertos, progresso por certificação, histórico de quizzes e opção de reiniciar o progresso.
- Os dados continuam salvos ao fechar e reabrir o aplicativo.

**Regra de conclusão de uma etapa:** leitura confirmada e pelo menos 2 acertos em 3 perguntas. Esse critério acompanha o estudo e não equivale à aprovação oficial. Uma etapa concluída não volta a pendente se o aluno refizer o quiz e errar.

## Requisito atendido

Da lista do trabalho, o projeto usa **banco de dados local** (SQLite, pelo pacote `sqflite`) para guardar:

- usuários e a sessão ativa;
- confirmação de leitura de cada etapa;
- acertos e data de conclusão;
- histórico de tentativas dos quizzes.

## Tecnologias

- [Flutter](https://flutter.dev) e Dart
- [`sqflite`](https://pub.dev/packages/sqflite): banco de dados SQLite local
- [`path`](https://pub.dev/packages/path): caminho do arquivo do banco
- [`crypto`](https://pub.dev/packages/crypto): hash SHA-256 das senhas
- Protótipo de interface elaborado no Figma

## Como executar

1. Instale o [Flutter](https://docs.flutter.dev/get-started/install) e o Android Studio (para as ferramentas do Android).
2. Clone o repositório:

   ```
   git clone https://github.com/pedrohfsouza97/estude_agil.git
   cd estude_agil
   ```

3. Baixe as dependências:

   ```
   flutter pub get
   ```

4. Conecte um celular Android com a depuração USB ativada e veja o identificador dele:

   ```
   flutter devices
   ```

5. Execute o aplicativo:

   ```
   flutter run -d IDENTIFICADOR_DO_APARELHO
   ```

## Estrutura do projeto

```
estude_agil/
├── lib/
│   └── main.dart        # telas, conteúdo das trilhas e acesso ao banco
├── assets/
│   └── guia/            # páginas 1 a 16 do Guia do Scrum 2020 (imagens)
├── pubspec.yaml         # dependências e assets
└── README.md
```

## Testes e limitações

- O aplicativo foi testado em um aparelho físico **Samsung Galaxy S20+** (Android 13), conectado por cabo USB. O emulador do Android Studio foi tentado, mas o processo era encerrado logo ao iniciar, por isso os testes foram feitos no celular.
- Não foram feitos testes em outros tamanhos de tela, em outras versões do Android nem em iOS.
- O login é local: não há servidor, recuperação de senha nem sincronização entre aparelhos.
- O conteúdo da trilha PMP é introdutório e não se baseia no PMBOK.
- Evoluções futuras: trilhas PSM II e CAPM e mais perguntas.

## Material do projeto

Pasta compartilhada com o documento, a apresentação e demais arquivos:
[Google Drive](https://drive.google.com/drive/folders/1mvQK4LpoE9OwH32bWtIolRuvJKOt26ay?usp=sharing)

## Referências

- Guia do Scrum 2020, de Ken Schwaber e Jeff Sutherland, licença [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/): [scrumguides.org](https://scrumguides.org)
- Certificações PSM I e PSPO: [scrum.org](https://www.scrum.org)
- Certificações PMP e CAPM: [pmi.org](https://www.pmi.org)
- Flutter e Dart: [flutter.dev](https://flutter.dev) · pacotes em [pub.dev](https://pub.dev)
- Claude (Anthropic), assistente de inteligência artificial utilizado como apoio ao desenvolvimento do código, à redação dos textos e à revisão do trabalho.
