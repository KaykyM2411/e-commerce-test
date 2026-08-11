# E-Commerce Test

API-only Rails 8 consumer/demo do [`huginn_datatable`](https://rubygems.org/gems/huginn_datatable) — uma gem de datatable/search para Active Record com PostgreSQL.

Expõe endpoints de datatable paginado com filtros, ranges, ordenação e busca tolerante (trigram / full-text), sobre um e-commerce fictício (`usuarios`, `produtos`, `pedidos` e `itens_pedidos`).

## Setup

```bash
bundle install
docker compose up -d   # PostgreSQL 17 em localhost:5433
bin/setup              # cria o banco e roda as migrations
```

`bin/setup` também já deixa o banco de teste pronto. Para dados de demonstração em volume (opcional):

```bash
bin/rails db:seed_demo
```

O seed usa a porta `COPY` do PostgreSQL e aceita o tamanho via env vars (valores default: 2M usuários, 300k produtos, 12M pedidos):

```bash
USUARIOS=10000 PRODUTOS=5000 PEDIDOS=50000 bin/rails db:seed_demo
```

## Endpoints

| Método | Rota | Descrição |
|---|---|---|
| GET | `/api/v1/produtos` | Datatable de produtos (page, per_page, search, filters, range_data, orders) |
| GET | `/api/v1/produtos/:id` | Detalhe de um produto |
| GET | `/api/v1/usuarios` | Datatable de usuários |
| GET | `/api/v1/usuarios/:id` | Usuário com os 5 pedidos mais recentes |
| GET | `/api/v1/pedidos` | Datatable de pedidos (suporta filtros/orders por associação `usuario.*`) |
| GET | `/api/v1/pedidos/:id` | Pedido completo com itens e produtos |
| GET | `/api/v1/usuarios/:usuario_id/pedidos` | Pedidos de um usuário |
| GET | `/api/v1/pedidos/relatorio` | Aggregates: total de pedidos, receita, ticket médio e contagem por status |

Exemplo com filtro de associação e ordenação:

```
GET /api/v1/pedidos?filters[usuario.email]=ana@example.com&orders[0][usuario.nome]=desc
```

### Formato da resposta

Todas as rotas de datatable respondem com:

```json
{
  "data": [ ... ],
  "total_count": 300000
}
```

Paginação é feita via `page` / `per_page`.

## Busca

A estratégia de busca é configurável em [`config/initializers/huginn.rb`](config/initializers/huginn.rb). As opções são:

- `:pg_trgm` — similaridade trigram + `unaccent`, tolerante a typos;
- `:full_text` — full-text search com stemming em português (default neste app, requer os índices GIN criados);
- `:unaccent` — `ILIKE` com normalização de acentos;
- `:simple` — busca `ILIKE` simples.

As migrations `db/migrate/*add_huginn*` criam as funções imutáveis `f_unaccent`/`f_tsvector` e os índices GIN (trigram + FTS) necessários.

## Testes

```bash
bin/rails test
```

Request specs de integração em [`test/integration/api/v1`](test/integration/api/v1) cobrem filtros próprios e por associação, ranges, orders, busca e o relatório.

## CI

`.github/workflows/ci.yml` roda `brakeman`, `rubocop` e a suite de testes contra o PostgreSQL 17.