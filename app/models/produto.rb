class Produto < ApplicationRecord
  has_many :itens_pedidos, class_name: "ItemPedido", dependent: :nullify

  searchable_columns :nome, :sku, :categoria
end
