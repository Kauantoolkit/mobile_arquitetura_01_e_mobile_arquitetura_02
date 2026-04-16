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




conformidade da entrega:

ignore nomes de repo e tudo mais, mas analise as entregas:



Atividade 04 – Construção de Aplicação Flutter com Arquitetura em Camadas

Objetivo
Nesta atividade você deverá desenvolver uma aplicação Flutter capaz de consumir uma API pública de produtos e exibir esses dados em uma interface simples. O foco principal da atividade não é apenas construir a interface, mas aplicar os conceitos de arquitetura em camadas e separação de responsabilidades apresentados em aula.

Ao final da atividade, espera-se que você seja capaz de organizar um projeto Flutter separando claramente as responsabilidades entre camadas de apresentação, domínio e acesso a dados.

Esta atividade é a atividade de número 1 do material Arquitetura - Aula 2, que você pode baixar aqui!

Requisitos da aplicação
A aplicação deverá:

consumir a API pública de produtos disponível em
https://fakestoreapi.com/products

converter os dados retornados pela API para objetos da aplicação

organizar o código utilizando as camadas arquiteturais estudadas

exibir na interface uma lista de produtos contendo pelo menos:

título

preço

imagem

Estrutura arquitetural esperada
O projeto deve separar o código nas seguintes camadas:

presentation — interface e interação com o usuário

domain — entidades e contratos de repositório

data — modelos, datasources e implementação de repositórios

core — utilitários comuns (rede, erros, etc.)

Entrega
O código da atividade deverá ser entregue em um repositório Git com o nome:

mobile_arquitetura_01
O repositório deve conter:

o projeto Flutter completo

código organizado conforme a arquitetura proposta

aplicação funcionando (executando a requisição da API e exibindo os produtos)





Atividade 05 – Evolução Arquitetural da Aplicação

Objetivo
Nesta atividade você deverá evoluir a aplicação construída na Atividade 1, incorporando melhorias arquiteturais comuns em aplicações reais.

O objetivo é compreender como uma arquitetura em camadas facilita a evolução do sistema sem comprometer sua organização estrutural.

Esta é a atividade 2 do material de aula Arquitetura - Aula 2 que pode ser baixar aqui!

Melhorias a serem implementadas
A aplicação deve ser refatorada para incluir:

1 — Estado da interface
A interface deve representar explicitamente os estados da aplicação:

carregando dados

erro na requisição

dados carregados com sucesso

2 — Tratamento de erros
A aplicação deve tratar falhas de comunicação com a API e informar o erro ao usuário.

3 — Cache local simples
Implementar um mecanismo simples de cache para armazenar os produtos carregados.
Caso a API não esteja disponível, o sistema deve utilizar os dados previamente carregados.

Requisitos arquiteturais
Durante a refatoração, a arquitetura em camadas deve ser mantida:

a UI não deve realizar chamadas HTTP diretamente

o ViewModel deve coordenar o estado da aplicação

o Repository deve decidir de onde os dados vêm

os DataSources devem executar apenas operações de IO

Entrega
O código desta atividade deve ser entregue em um repositório Git separado com o nome:

mobile_arquitetura_02
Este repositório deve conter:

a versão evoluída da aplicação

implementação do estado da interface

tratamento de erros

mecanismo de cache

Atividade 06 – Gerenciamento de Estado

Nesta atividade será utilizado o projeto desenvolvido em aula, disponível no repositório:

https://github.com/jeffersonspeck/state_mobile_aula01

Esse projeto apresenta três abordagens diferentes de gerenciamento de estado em aplicações Flutter: Provider, Riverpod e BLoC. Cada uma dessas abordagens demonstra formas distintas de organizar o fluxo de dados entre a lógica da aplicação e a interface do usuário.

Nesta atividade, os estudantes deverão modificar o projeto existente para implementar um pequeno sistema de controle de favoritos em uma lista de produtos.

Objetivo da atividade
Esta atividade tem como objetivos:

compreender como o estado da aplicação controla o comportamento da interface

aplicar uma estratégia de gerenciamento de estado em Flutter

modificar uma aplicação existente

observar como mudanças no estado provocam atualização automática da interface

Descrição da aplicação
A aplicação deverá possuir uma única tela contendo uma lista de produtos.

Cada produto deve apresentar:

nome do produto

preço

botão para marcar ou desmarcar como favorito

Exemplo conceitual da interface:

Produtos

Notebook - R$ 3500   [☆]
Mouse - R$ 120       [☆]
Teclado - R$ 250     [★]
Monitor - R$ 900     [☆]
O ícone deve indicar se o produto está favoritado ou não.

Quando o usuário clicar no botão, o estado do produto deve ser alterado e a interface deve ser atualizada automaticamente.

Modelo de produto
Um possível modelo de dados para representar produtos é:

class Product {

  final String name;
  final double price;
  bool favorite;

  Product({
    required this.name,
    required this.price,
    this.favorite = false,
  });

}
Gerenciamento de estado
Os estudantes devem escolher uma das estratégias de gerenciamento de estado estudadas:

Provider

Riverpod

BLoC

O estado da aplicação deve manter:

a lista de produtos

o status de favorito de cada produto

Sempre que um produto for marcado ou desmarcado como favorito, a interface deve refletir automaticamente essa mudança.

Funcionalidades obrigatórias
A aplicação deve permitir:

visualizar uma lista de produtos

marcar um produto como favorito

remover um produto dos favoritos

atualização automática da interface quando o estado mudar

Desafios opcionais
Para estudantes que desejarem aprofundar a atividade, podem ser implementadas funcionalidades adicionais, como:

contador de produtos favoritos

destaque visual para produtos favoritados

filtro para mostrar apenas produtos favoritos

Atividade 08 – Expansão de Navegação com Fake API

Nesta atividade, você deverá dar continuidade ao projeto desenvolvido em aula, no qual a aplicação consome uma Fake API para listar produtos.

Agora, o objetivo é evoluir esse projeto para trabalhar com múltiplas telas, organizando melhor o fluxo da aplicação. Em vez de manter apenas uma tela de listagem, você deverá transformar o sistema em uma aplicação com navegação entre páginas.

A aplicação deverá possuir, no mínimo, três telas:

uma tela inicial

uma tela de listagem de produtos

uma tela de detalhes do produto

O fluxo esperado é:

Tela Inicial
→ Tela de Produtos
→ Tela de Detalhes do Produto

Objetivos da atividade

Com esta atividade, espera-se que você seja capaz de:

aplicar navegação entre telas em um projeto já existente

utilizar Navigator.push() e Navigator.pop()

organizar a aplicação em múltiplas páginas

enviar dados de uma tela para outra

compreender melhor o fluxo da interface em aplicações Flutter

Orientações gerais

Você deve utilizar como base o projeto já criado em aula com consumo da Fake API. Não é necessário refazer o projeto do zero. A proposta é aproveitar a estrutura existente e expandi-la.

Seu projeto deve:

possuir uma tela inicial com algum botão ou ação para acessar a listagem de produtos

manter a listagem de produtos carregados da Fake API

permitir que o usuário clique em um produto da lista

abrir uma tela de detalhes ao selecionar um item

exibir informações do produto selecionado na tela de detalhes

permitir voltar para a tela anterior usando a navegação do Flutter

Requisitos mínimos

Sua aplicação deve conter:

Tela inicial
Deve funcionar como ponto de entrada da aplicação, contendo pelo menos um botão para abrir a tela de produtos.

Tela de produtos
Deve exibir os produtos obtidos da Fake API. Mostre pelo menos:

nome do produto

preço

Tela de detalhes
Deve receber os dados do produto selecionado e exibir informações mais completas, como:

nome

preço

descrição

imagem
Se houver outras informações disponíveis na API, você pode exibi-las também.

Desafios opcionais

Caso queira aprofundar a atividade, você pode implementar melhorias como:

uso de rotas nomeadas

indicador de carregamento

tratamento de erro ao buscar a API

botão para voltar diretamente à tela inicial

melhoria visual da tela de detalhes

exibição de categoria ou avaliação do produto

Entrega

Para concluir a atividade, você deverá entregar:

o link do repositório do seu projeto

as respostas do questionário abaixo

O que enviar

No campo de entrega da atividade, cole:

Link do repositório GitHub com o projeto

Respostas das questões

Atividade 09 – Implementação de CRUD

Estrutura do Projeto
Para garantir que o projeto esteja "minimamente estruturado", recomendo a seguinte divisão de pastas:

models/: Definição da classe Product.

services/: Classe ProductService encapsulando o http.

screens/: Arquivos para ProductListScreen, ProductFormScreen (usada para cadastro e edição) e ProductDetailScreen.

widgets/: Componentes reutilizáveis, como cartões de produto ou campos de formulário.

Componentes Principais
1. Modelo de Produto (models/product.dart)
O modelo deve ser capaz de converter os dados da API para objetos Dart e vice-versa.

Utilize métodos fromJson e toJson.

Certifique-se de incluir os campos necessários (id, nome, preço, descrição, etc.).

2. Serviço de API (services/product_service.dart) (Depende da arquitetura)
Esta classe centraliza as chamadas de rede, facilitando a manutenção:

fetchProducts(): Retorna a lista completa (GET).

addProduct(Product product): Envia os dados para o servidor (POST).

updateProduct(Product product): Atualiza um registro existente (PUT).

deleteProduct(String id): Remove o produto da base (DELETE).

3. Navegação e Telas
Listagem: Utilize um FutureBuilder ou gerenciamento de estado para exibir a lista. Adicione um ListTile com botões de ação (editar/excluir) ou similar.

Formulário: Utilize a mesma tela para Cadastro e Edição. A diferença será a presença ou não de um id no objeto passado para a tela.

Detalhes: Uma tela simples para exibir informações completas que não cabem na listagem principal.




