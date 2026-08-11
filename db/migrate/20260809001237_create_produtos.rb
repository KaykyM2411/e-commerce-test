class CreateProdutos < ActiveRecord::Migration[8.0]
  def change
    create_table :produtos do |t|
      t.string   :nome,             null: false
      t.string   :sku,              null: false
      t.string   :categoria,        default: ""
      t.integer  :preco_centavos,   null: false, default: 0
      t.integer  :estoque,          null: false, default: 0

      t.timestamps
    end

    add_index :produtos, :sku, unique: true
    add_index :produtos, :nome, using: :gin, opclass: :gin_trgm_ops
    add_index :produtos, :categoria
  end
end
