
# (essa anotação está aqui mais pra não me perder mesmo): Esse repositório foi usado tanto para as atividades 4, 4b, 5

# Respostas Questionário de Reflexão (questionario atividade 05)

## 1. Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.

O mecanismo de cache foi implementado na **camada de dados**, mais especificamente na classe `ProductCacheDatasource`. Essa classe é responsável por armazenar em memória os produtos já buscados anteriormente, fornecendo métodos para salvar, recuperar e limpar os dados em cache.

Essa decisão é adequada porque, na Clean Architecture, a camada de dados é a que lida diretamente com fontes de dados externas – sejam elas remotas (API) ou locais (cache, banco de dados). O cache é, essencialmente, uma fonte de dados local temporária, portanto faz todo sentido que ele esteja nessa camada.

Além disso, ao colocar o cache na camada de dados, mantemos a **separação de preocupações**: a camada de domínio (que contém as regras de negócio) não precisa saber se os dados vêm da rede ou do cache, e a camada de apresentação (UI) só se preocupa com como exibir os dados. O repositório (`ProductRepositoryImpl`) fica responsável por orquestrar a prioridade das fontes: tenta primeiro a rede, e se falhar, recorre ao cache. Isso deixa o código mais organizado, testável e fácil de modificar no futuro.

## 2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?

O ViewModel faz parte da **camada de apresentação** e sua responsabilidade principal é gerenciar o estado da UI e preparar os dados para exibição. Se ele fizesse chamadas HTTP diretamente, estaria assumindo uma responsabilidade que pertence à **camada de dados** – a de acessar a infraestrutura de rede.

Isso traria vários problemas:

- **Acoplamento forte**: O ViewModel ficaria dependente de detalhes de implementação da rede (URLs, bibliotecas HTTP, parsing de JSON), tornando difícil trocar a fonte de dados no futuro.
- **Dificuldade de teste**: Testar o ViewModel exigiria mock de rede, o que é mais complexo do que mock de um repositório abstrato.
- **Violação do princípio de responsabilidade única**: O ViewModel passaria a cuidar de lógica de UI **e** de lógica de acesso a dados, ficando inchado e difícil de manter.
- **Dificuldade de reutilização**: A lógica de rede estaria espalhada por vários ViewModels, em vez de estar centralizada em um único lugar (o repositório).

No projeto, o ViewModel só se comunica com o `ProductRepository` (uma interface abstrata), que por sua vez delega as chamadas HTTP para o `ProductRemoteDatasource`. Essa indireção garante que cada camada tenha uma única responsabilidade e que mudanças na infraestrutura não afetem a apresentação.

## 3. O que poderia acontecer se a interface acessasse diretamente o DataSource?

Se a interface (tela/widget) acessasse diretamente o `ProductRemoteDatasource` ou o `ProductCacheDatasource`, estaríamos “furando” as camadas da arquitetura, o que geraria uma série de consequências negativas:

- **Perda do cache automático**: A lógica de fallback (tentar rede, depois cache) está no repositório. Se a UI chama o DataSource direto, ela teria que replicar essa lógica, aumentando a complexidade e a chance de bugs.
- **Acoplamento com detalhes de implementação**: A UI ficaria dependente de como os dados são obtidos (ex.: formato da URL, biblioteca HTTP usada). Qualquer mudança nesses detalhes exigiria alterar a interface.
- **Dificuldade para testar**: Testes de widget precisariam simular respostas de rede, em vez de apenas mockar um repositório.
- **Violação da Clean Architecture**: A regra de dependência (camadas externas dependem de camadas internas) seria quebrada, pois a apresentação (mais externa) estaria dependendo de uma implementação concreta da camada de dados (mais interna).
- **Duplicação de código**: Várias telas fariam a mesma chamada, repetindo tratamento de erro, parsing, etc.

No projeto, a interface (`ProductPage`) só conversa com o `ProductViewModel`, que por sua vez usa o repositório. Isso mantém o fluxo controlado e organizado.

## 4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?

A arquitetura segue o princípio da **inversão de dependência**: módulos de alto nível (como o ViewModel) não dependem de módulos de baixo nível (como o DataSource), mas sim de **abstrações**. No caso, o ViewModel depende apenas da interface `ProductRepository`, e não da implementação concreta que acessa a API.

Para substituir a API por um banco de dados local, bastaria:

1. Criar uma nova fonte de dados, por exemplo `ProductLocalDatasource`, que em vez de fazer HTTP, consulta um banco SQLite ou Hive.
2. Manter a mesma interface `ProductRepository`, mas alterar a implementação `ProductRepositoryImpl` para usar o novo `ProductLocalDatasource` (sozinho ou em conjunto com o cache, conforme a necessidade).
3. Ajustar a injeção de dependência no `main.dart` para passar a nova implementação para o ViewModel.

**Nenhuma alteração seria necessária** na camada de domínio (entidades, regras de negócio) nem na camada de apresentação (ViewModel, páginas, widgets). O ViewModel continuaria chamando `repository.getProducts()` da mesma forma, sem saber que os dados agora vêm de um banco local.

Essa flexibilidade é um dos grandes benefícios da Clean Architecture: isolar as mudanças de infraestrutura, permitindo que a aplicação evolua sem impactar as regras de negócio e a experiência do usuário.

---




# Projeto:




# mobile_arquitetura_01

Um projeto Flutter demonstrando clean architecture com camadas de dados, domínio e apresentação. Consome a API FakeStore (https://fakestoreapi.com/products).

## Arquitetura

Este projeto segue os princípios de Clean Architecture com as seguintes camadas:

```
lib/
  core/
    errors/
      failure.dart          # Classe de exceção para falhas
    network/
      http_client.dart     # Wrapper do cliente HTTP usando o pacote http
  domain/
    entities/
      product.dart         # Entidade Product (imutável)
    repositories/
      product_repository.dart  # Interface abstrata do repositório
  data/
    models/
      product_model.dart   # ProductModel com serialização JSON
    datasources/
      product_remote_datasource.dart   # Fonte de dados da API remota
      product_cache_datasource.dart    # Fonte de dados de cache em memória
    repositories/
      product_repository_impl.dart     # Implementação do repositório
  presentation/
    viewmodels/
      product_state.dart    # Classe de estado para produtos
      product_viewmodel.dart # ViewModel gerenciando o estado dos produtos
    pages/
      product_page.dart     # Página principal exibindo produtos
    widgets/
      product_tile.dart    # Widget de cartão de produto reutilizável
  main.dart                 # Ponto de entrada do app com configuração de DI
```

## Pacote HTTP Utilizado

Este projeto usa o pacote **http** (versão 1.6.0) para fazer requisições de rede. É um cliente HTTP simples e leve para Dart/Flutter.

## Como Executar

1. **Instalar dependências:**
   ```bash
   flutter pub get
   ```

2. **Executar o app:**
   ```bash
   flutter run
   ```

3. **Build para Android:**
   ```bash
   flutter build apk
   ```

4. **Build para iOS:**
   ```bash
   flutter build ios
   ```

## Melhorias a serem implementadas (e já aplicadas)

1 — Estado da interface
- A interface representa explicitamente os estados da aplicação:
  - carregando dados (`ProductState.isLoading = true`)
  - erro na requisição (`ProductState.error != null`)
  - dados carregados com sucesso (`ProductState.products`)

2 — Tratamento de erros
- A aplicação trata falhas de comunicação com a API:
  - `ProductViewModel.loadProducts()` capta `Failure` e erro genérico
  - informa o usuário com mensagem e permite retry

3 — Cache local simples
- Implementado em `ProductCacheDatasource` (cache em memória)
- `ProductRepositoryImpl` usa cache se API não estiver disponível

## Como Testar Falha de Rede

Para testar o tratamento de erros e comportamento de cache:

1. **Testar sem internet:**
   - Desconecte seu dispositivo/computador da rede
   - Toque no botão de atualizar (FAB)
   - Se os produtos foram carregados antes, aparecerão do cache
   - Se nenhum produto foi carregado antes, você verá uma mensagem de erro

2. **Simular falha de rede no código:**
   - Você pode modificar o `ProductRemoteDatasource` para lançar uma exceção
   - Ou alterar temporariamente a URL da API para um endpoint inválido

## Tratamento de Erros

- **Erros de rede:** Exibe a mensagem "Não foi possível carregar os produtos"
- **Fallback de cache:** Se a rede falhar mas existir cache, exibe os produtos em cache
- **Estado vazio:** Exibe mensagem apropriada quando não houver produtos disponíveis

## Funcionalidades

- Clean Architecture (camadas de dados, domínio e apresentação)
- Consome https://fakestoreapi.com/products
- Cache em memória para suporte offline
- Tratamento de erros com mensagens amigáveis
- Pull-to-refresh via botão FAB
- Null safety
- Material Design 3

## Atividade solicitada: requisitos atendidos

- Estado da interface:
  - `carregando` (estado `isLoading` no `ProductState`)
  - `erro` (campo `error` no `ProductState` e exibição de mensagem com botão de retry)
  - `sucesso` (lista de produtos exibida via `ListView`)
- Tratamento de erros:
  - captura exception no `ViewModel` e mostra mensagem apropriada
  - fallback para cache se API falhar
- Cache local simples:
  - `ProductCacheDatasource` mantém produtos em memória
  - `ProductRepositoryImpl` salva no cache e usa em caso de falha remota
- Requisitos arquiteturais:
  - UI não faz HTTP (apenas exibe estado do `ViewModel`)
  - ViewModel coordena o estado (`ProductViewModel`)
  - Repository decide origem dos dados (`ProductRepositoryImpl`)
  - DataSources fazem apenas IO (`ProductRemoteDatasource`, `ProductCacheDatasource`)

## Commits

- `init: flutter project mobile_arquitetura_01` - Configuração inicial do projeto Flutter
- Commits adicionais para implementação de cada camada

## Versão

v1.0.0

## Questionário de Reflexão (Atividade 2)

1. Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.

- O cache foi implementado na camada de dados, especificamente em `lib/data/datasources/product_cache_datasource.dart`, e utilizado pelo `ProductRepositoryImpl` em `lib/data/repositories/product_repository_impl.dart`.
- Isso é adequado porque a camada de dados é responsável por operações de IO e persistência. O Repositório decide de onde virão os dados (API remota ou cache), mantendo o domínio e a apresentação desacoplados das fontes de dados concretas.

2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?

- O ViewModel é a camada de apresentação e deve apenas coordenar o estado da UI e lógica de exibição. Chamadas HTTP no ViewModel violariam a separação de responsabilidades, tornariam testes mais difíceis e amarrariam a UI à infraestrutura de rede.

3. O que poderia acontecer se a interface acessasse diretamente o DataSource?

- A UI ficaria acoplada à implementação de dados, dificultando mudanças futuras (troca de API, cache, banco local). Além disso, a lógica de erros e fallback ficaria espalhada pela interface em vez de centralizada, gerando repetição, fragilidade e menor testabilidade.

4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?

- Como a UI depende apenas do ViewModel e o domínio depende de interfaces de repositório, basta alterar/implementar outro DataSource (ex: `LocalDatasource`) e ajustar a lógica no repositório (`ProductRepositoryImpl`) para priorizar local vs remoto. O restante da camada de apresentação permanece inalterado.


