class CreateItensPedido < ActiveRecord::Migration[8.0]
  def change
    create_table :itens_pedidos do |t|
      t.references :pedido,  null: false, foreign_key: true
      t.references :produto, null: false, foreign_key: true
      t.integer    :quantidade,        null: false, default: 1
      t.integer    :preco_unitario_centavos, null: false, default: 0

      t.timestamps
    end
  end
end
