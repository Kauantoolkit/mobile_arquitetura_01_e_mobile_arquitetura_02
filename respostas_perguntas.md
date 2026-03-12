# Respostas sobre a Arquitetura do Projeto

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


