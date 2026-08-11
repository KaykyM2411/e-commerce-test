class AddHuginnTrigramIndexes < ActiveRecord::Migration[8.0]
  def up
    enable_extension "unaccent" unless connection.extension_enabled?("unaccent")

    # The pg builtin unaccent() is STABLE (not IMMUTABLE) since PG 13+, so it
    # cannot be used in an index expression. Wrap it in an IMMUTABLE function
    # that always pins the default dictionary.
    execute <<~SQL
      CREATE OR REPLACE FUNCTION public.f_unaccent(text)
      RETURNS text AS $$
        SELECT public.unaccent('public.unaccent', $1);
      $$
      LANGUAGE sql IMMUTABLE PARALLEL SAFE;
    SQL

    add_index :usuarios, "public.f_unaccent(nome) gin_trgm_ops", using: :gin, name: "index_usuarios_nome_trgm"

    add_index :usuarios, "public.f_unaccent(email) gin_trgm_ops", using: :gin, name: "index_usuarios_email_trgm"

    add_index :usuarios, "public.f_unaccent(cidade) gin_trgm_ops", using: :gin, name: "index_usuarios_cidade_trgm"

    add_index :usuarios, "public.f_unaccent(estado) gin_trgm_ops", using: :gin, name: "index_usuarios_estado_trgm"

    add_index :produtos, "public.f_unaccent(nome) gin_trgm_ops", using: :gin, name: "index_produtos_nome_trgm"

    add_index :produtos, "public.f_unaccent(sku) gin_trgm_ops", using: :gin, name: "index_produtos_sku_trgm"

    add_index :produtos, "public.f_unaccent(categoria) gin_trgm_ops", using: :gin, name: "index_produtos_categoria_trgm"

    add_index :pedidos, "public.f_unaccent(status) gin_trgm_ops", using: :gin, name: "index_pedidos_status_trgm"
  end

  def down
    remove_index :usuarios, name: "index_usuarios_nome_trgm"

    remove_index :usuarios, name: "index_usuarios_email_trgm"

    remove_index :usuarios, name: "index_usuarios_cidade_trgm"

    remove_index :usuarios, name: "index_usuarios_estado_trgm"

    remove_index :produtos, name: "index_produtos_nome_trgm"

    remove_index :produtos, name: "index_produtos_sku_trgm"

    remove_index :produtos, name: "index_produtos_categoria_trgm"

    remove_index :pedidos, name: "index_pedidos_status_trgm"

    execute "DROP FUNCTION IF EXISTS public.f_unaccent(text)"
  end
end
