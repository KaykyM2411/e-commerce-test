class CreateUsuarios < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pg_trgm"
    enable_extension "unaccent"

    create_table :usuarios do |t|
      t.string   :nome,             null: false
      t.string   :email,            null: false
      t.string   :cidade,           default: ""
      t.string   :estado,           default: ""
      t.string   :telefone,         default: ""
      t.jsonb    :tags,             null: false, default: {}
      t.integer  :pedidos_count,    null: false, default: 0
      t.integer  :total_gasto,      null: false, default: 0

      t.timestamps
    end

    add_index :usuarios, :email, unique: true
    add_index :usuarios, :nome, using: :gin, opclass: :gin_trgm_ops
    add_index :usuarios, :cidade
    add_index :usuarios, :tags, using: :gin
  end

  def down
    drop_table :usuarios
    disable_extension "unaccent"
    disable_extension "pg_trgm"
  end
end
