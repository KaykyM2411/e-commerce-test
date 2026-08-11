require "pg"
require "time"

namespace :db do
  desc "Seeds a heavy e-commerce dataset (usuarios/produtos/pedidos/itens) via COPY"
  task seed_demo: :environment do
    SeedDemo.new(
      usuarios: ENV.fetch("USUARIOS", "2000000").to_i,
      produtos: ENV.fetch("PRODUTOS", "300000").to_i,
      pedidos: ENV.fetch("PEDIDOS", "12000000").to_i,
      itens_por_pedido: ENV.fetch("ITENS_POR_PEDIDO", "3").to_i
    ).call!
  end
end
