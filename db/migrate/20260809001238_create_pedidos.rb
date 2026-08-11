class CreatePedidos < ActiveRecord::Migration[8.0]
  def change
    create_table :pedidos do |t|
      t.references :usuario,    null: false, foreign_key: true
      t.string     :status,     null: false, default: "pendente"
      t.integer    :total_centavos, null: false, default: 0
      t.datetime   :criado_em,  null: false

      t.timestamps
    end

    add_index :pedidos, :status
    add_index :pedidos, :criado_em
    add_index :pedidos, [ :usuario_id, :criado_em ]
  end
end
