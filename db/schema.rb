# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_08_10_212721) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "itens_pedidos", force: :cascade do |t|
    t.bigint "pedido_id", null: false
    t.bigint "produto_id", null: false
    t.integer "quantidade", default: 1, null: false
    t.integer "preco_unitario_centavos", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pedido_id"], name: "index_itens_pedidos_on_pedido_id"
    t.index ["produto_id"], name: "index_itens_pedidos_on_produto_id"
  end

  create_table "pedidos", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.string "status", default: "pendente", null: false
    t.integer "total_centavos", default: 0, null: false
    t.datetime "criado_em", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "f_unaccent((status)::text) gin_trgm_ops", name: "index_pedidos_status_trgm", using: :gin
    t.index ["criado_em"], name: "index_pedidos_on_criado_em"
    t.index ["status"], name: "index_pedidos_on_status"
    t.index ["usuario_id", "criado_em"], name: "index_pedidos_on_usuario_id_and_criado_em"
    t.index ["usuario_id"], name: "index_pedidos_on_usuario_id"
    t.index ["usuario_id"], name: "index_pedidos_on_usuario_id_cover_total_status", include: ["total_centavos", "status"]
  end

  create_table "produtos", force: :cascade do |t|
    t.string "nome", null: false
    t.string "sku", null: false
    t.string "categoria", default: ""
    t.integer "preco_centavos", default: 0, null: false
    t.integer "estoque", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "f_tsvector((categoria)::text)", name: "index_produtos_categoria_fts", using: :gin
    t.index "f_tsvector((nome)::text)", name: "index_produtos_nome_fts", using: :gin
    t.index "f_tsvector((sku)::text)", name: "index_produtos_sku_fts", using: :gin
    t.index "f_unaccent((categoria)::text) gin_trgm_ops", name: "index_produtos_categoria_trgm", using: :gin
    t.index "f_unaccent((nome)::text) gin_trgm_ops", name: "index_produtos_nome_trgm", using: :gin
    t.index "f_unaccent((sku)::text) gin_trgm_ops", name: "index_produtos_sku_trgm", using: :gin
    t.index ["categoria"], name: "index_produtos_on_categoria"
    t.index ["nome"], name: "index_produtos_on_nome", opclass: :gin_trgm_ops, using: :gin
    t.index ["sku"], name: "index_produtos_on_sku", unique: true
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "nome", null: false
    t.string "email", null: false
    t.string "cidade", default: ""
    t.string "estado", default: ""
    t.string "telefone", default: ""
    t.jsonb "tags", default: {}, null: false
    t.integer "pedidos_count", default: 0, null: false
    t.integer "total_gasto", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "f_tsvector((email)::text)", name: "index_usuarios_email_fts", using: :gin
    t.index "f_tsvector((nome)::text)", name: "index_usuarios_nome_fts", using: :gin
    t.index "f_unaccent((cidade)::text) gin_trgm_ops", name: "index_usuarios_cidade_trgm", using: :gin
    t.index "f_unaccent((email)::text) gin_trgm_ops", name: "index_usuarios_email_trgm", using: :gin
    t.index "f_unaccent((estado)::text) gin_trgm_ops", name: "index_usuarios_estado_trgm", using: :gin
    t.index "f_unaccent((nome)::text) gin_trgm_ops", name: "index_usuarios_nome_trgm", using: :gin
    t.index ["cidade"], name: "index_usuarios_on_cidade"
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["nome"], name: "index_usuarios_on_nome", opclass: :gin_trgm_ops, using: :gin
    t.index ["tags"], name: "index_usuarios_on_tags", using: :gin
  end

  add_foreign_key "itens_pedidos", "pedidos", on_delete: :cascade
  add_foreign_key "itens_pedidos", "produtos"
  add_foreign_key "pedidos", "usuarios", on_delete: :cascade
end
