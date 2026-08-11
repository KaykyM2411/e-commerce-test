class AddHuginnFtsIndexes < ActiveRecord::Migration[8.0]
  def up
    # to_tsvector(regconfig, text) is STABLE (not IMMUTABLE), so it cannot be
    # used in an index expression as-is. Wrap it in an IMMUTABLE function that
    # always pins the configured dictionary.
    execute <<~SQL
      CREATE OR REPLACE FUNCTION public.f_tsvector(text)
      RETURNS tsvector AS $$
        SELECT to_tsvector('portuguese', $1);
      $$
      LANGUAGE sql IMMUTABLE PARALLEL SAFE;
    SQL

    add_index :usuarios, "public.f_tsvector(nome)", using: :gin, name: "index_usuarios_nome_fts"

    add_index :usuarios, "public.f_tsvector(email)", using: :gin, name: "index_usuarios_email_fts"

    add_index :produtos, "public.f_tsvector(nome)", using: :gin, name: "index_produtos_nome_fts"

    add_index :produtos, "public.f_tsvector(sku)", using: :gin, name: "index_produtos_sku_fts"

    add_index :produtos, "public.f_tsvector(categoria)", using: :gin, name: "index_produtos_categoria_fts"
  end

  def down
    remove_index :usuarios, name: "index_usuarios_nome_fts"

    remove_index :usuarios, name: "index_usuarios_email_fts"

    remove_index :produtos, name: "index_produtos_nome_fts"

    remove_index :produtos, name: "index_produtos_sku_fts"

    remove_index :produtos, name: "index_produtos_categoria_fts"

    execute "DROP FUNCTION IF EXISTS public.f_tsvector(text)"
  end
end
