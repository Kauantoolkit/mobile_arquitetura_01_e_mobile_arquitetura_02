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


