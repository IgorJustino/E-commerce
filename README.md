Claro, aqui está a versão do `README.md` sem nenhum emoji.

-----

# Backend de E-commerce com Supabase

Este repositório contém o backend completo para um sistema de e-commerce, construído com **Supabase**. O projeto foi projetado para gerenciar todas as operações essenciais de uma loja virtual, desde o cadastro de usuários até a geração de relatórios de vendas, com foco em segurança e automação.

## Funcionalidades Principais

  * **Autenticação e Gerenciamento de Usuários**: Cadastro e login para clientes e administradores.
  * **Catálogo de Produtos**: Gerenciamento completo de produtos da loja.
  * **Gerenciamento de Pedidos**: Ciclo completo de criação e acompanhamento de pedidos.
  * **Endereços**: Armazenamento de múltiplos endereços de entrega e cobrança por usuário.
  * **Sistema de Pagamentos**: Estrutura para registro de transações financeiras.
  * **Segurança com RLS**: Políticas de *Row Level Security* que garantem que usuários acessem apenas seus próprios dados.
  * **Automação com Triggers e Functions**: Cálculos automáticos de totais de pedidos e atualização de timestamps.
  * **Relatórios Otimizados**: *Views* pré-configuradas para análise de vendas e consulta de pedidos.

## Tecnologias Utilizadas

  * **Supabase**: Utilizado para banco de dados (PostgreSQL), autenticação, RLS e Functions.
  * **Node.js**: Ambiente de execução para o gerenciamento de pacotes.
  * **Docker**: Utilizado pela Supabase CLI para executar o ambiente de desenvolvimento local.
  * **SQL/PLpgSQL**: Linguagem principal para a criação de migrations, triggers e functions.

## Começando

Siga as instruções abaixo para configurar e executar o ambiente de desenvolvimento localmente.

### Pré-requisitos

Certifique-se de que você possui as seguintes ferramentas instaladas em sua máquina:

| Ferramenta                                           | Versão Mínima | Descrição                                    |
| ---------------------------------------------------- | ------------- | -------------------------------------------- |
| [Node.js](https://nodejs.org/)                       | 18.x          | Ambiente de execução JavaScript              |
| [npm](https://www.npmjs.com/)                        | 9.x           | Gerenciador de pacotes do Node.js            |
| [Supabase CLI](https://supabase.com/docs/guides/cli) | 1.175.x       | Ferramenta de linha de comando do Supabase   |
| [Docker](https://www.docker.com/)                    | 24.x          | Dependência para executar o Supabase localmente |

### Instalação

**1. Clone o repositório**

```bash
git clone https://github.com/igorjustino/ecommerce-supabase.git
cd ecommerce-supabase
```

**2. Instale as dependências do projeto**

Este comando instalará a Supabase CLI como uma dependência de desenvolvimento.

```bash
npm install
```

**3. Inicie o ambiente local do Supabase**

Este comando utiliza o Docker para iniciar todos os serviços do Supabase.

```bash
supabase start
```

Após a execução, você receberá as seguintes URLs de acesso:

```
API URL: http://localhost:54321
DB URL: postgresql://postgres:postgres@localhost:54322/postgres
Studio URL: http://localhost:54323
```

Acesse o **Supabase Studio** em `http://localhost:54323` para gerenciar seu ambiente local.

**4. Aplique as Migrations**

Para criar a estrutura do banco de dados (tabelas, triggers, views e policies), execute o comando abaixo.

```bash
supabase db reset
```

Este comando irá limpar o banco de dados local e aplicar sequencialmente todos os arquivos de migração localizados na pasta `supabase/migrations`.

**5. Populando o Banco de Dados**

Para testar a aplicação, é necessário criar usuários e inserir dados de exemplo.

  * **Criar Usuários**:

    1.  Acesse o Supabase Studio (`http://localhost:54323`).
    2.  Navegue até **Authentication \> Users** e clique em **Create User**.
    3.  Crie usuários de teste (clientes e administradores). Marque a opção **Auto Confirm User** para simplificar o processo.

  * **Inserir Dados de Teste**:

    1.  Acesse o **SQL Editor**.
    2.  Copie e execute os comandos SQL do arquivo `TEST_PLAN.md` para popular as tabelas `products`, `addresses`, `orders`, etc.

## Testes

A validação das funcionalidades pode ser realizada manualmente seguindo os passos descritos no arquivo [`Teste_relatorio.md`](docs/Teste_relatorio.md). O plano de testes inclui:

1.  Scripts de inserção de dados para todas as tabelas.
2.  Consultas de validação para verificar a integridade dos dados.
3.  Testes de políticas de **Row Level Security (RLS)**, simulando o acesso de diferentes usuários.
4.  Consultas às *views* para validar os relatórios gerados.

## Segurança: Row Level Security (RLS)

  * **Clientes** possam visualizar e modificar apenas seus próprios dados (pedidos, endereços, etc.).
  * **Administradores** (`admin` role) tenham acesso irrestrito a todos os dados do sistema para fins de gerenciamento.

As políticas estão definidas no arquivo de migração `20251015000300_enable_rls_and_policies.sql`.

## Views para Relatórios

Para facilitar a consulta e a geração de relatórios, foram implementadas as seguintes views:

| View                        | Finalidade                                                   |
| --------------------------- | ------------------------------------------------------------ |
| `order_summary_view`        | Exibe um resumo dos pedidos, incluindo dados do cliente e total. |
| `order_details_view`        | Detalha os itens, produtos e quantidades de cada pedido.      |
| `top_selling_products_view` | Lista os produtos mais vendidos (opcional).                  |

## Documentação Adicional

  * [Guia de Testes Manuais (Teste_relatorio.md)](docs/Teste_relatorio.md)
  * [Documentação Oficial do Supabase](https://supabase.com/docs)
