class Pedido < ApplicationRecord
  belongs_to :usuario

  has_many :itens_pedidos, class_name: "ItemPedido", dependent: :destroy

  has_many :produtos, through: :itens_pedidos, source: :produto

  enum :status, {
    pendente: "pendente",
    pago: "pago",
    enviado: "enviado",
    entregue: "entregue",
    cancelado: "cancelado"
  }, validate: true

  searchable_columns usuario: [ :nome, :email ]
end
