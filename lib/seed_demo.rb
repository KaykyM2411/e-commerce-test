# Generates a heavy e-commerce dataset (usuarios/produtos/pedidos/itens)
# via PostgreSQL COPY for realistic datatable/search benchmarks.
class SeedDemo
  NOMES = %w[João Maria José Ana Pedro Luiza Paulo Cláudia Carlos Beatriz Rafael Helena Gabriel Alice Marina Felipe Vanessa].freeze
  SOBRENOMES = %w[Silva Santos Oliveira Lima Pereira Costa Rodrigues Almeida Nascimento Carvalho Araújo Rocha Ribeiro Gomes Ferreira Barros].freeze
  CIDADES = [ "São Paulo", "Rio de Janeiro", "Belo Horizonte", "Porto Alegre", "Curitiba", "Salvador", "Recife", "Fortaleza", "Manaus", "Brasília", "Goiânia", "Campinas", "Florianópolis" ].freeze
  ESTADOS = %w[SP RJ MG RS PR BA PE CE DF GO SC ES AM].freeze
  CATEGORIAS = %w[Eletrônicos Vestuário Calçados Móveis Livros Esportes Brinquedos Beleza Alimentos Periféricos].freeze
  PREFIXOS = %w[Supreme Alpha Beta Gamma Delta Omega Prime Ultra Mega Hyper].freeze
  SUFIXOS = %w[Pro Plus Lite Max Air Mini Go Elite].freeze
  STATUS = %w[pendente pago enviado entregue cancelado].freeze
  TAG_SET = %w[vip bronze prata ouro].freeze
  DOMINIOS = %w[gmail.com hotmail.com yahoo.com.br uol.com.br outlook.com terra.com.br].freeze
  TEMPO_INICIO = Time.utc(2021, 1, 1).to_i
  TEMPO_FIM = Time.utc(2025, 12, 31).to_i

  SECONDARY_INDEXES = %w[
    index_usuarios_on_email
    index_usuarios_on_nome
    index_usuarios_on_cidade
    index_usuarios_on_tags
    index_produtos_on_sku
    index_produtos_on_nome
    index_produtos_on_categoria
    index_pedidos_on_status
    index_pedidos_on_criado_em
    index_pedidos_on_usuario_id
    index_pedidos_on_usuario_id_and_criado_em
    index_pedidos_on_usuario_id_cover_total_status
    index_itens_pedidos_on_produto_id
    index_itens_pedidos_on_pedido_id
  ].freeze

  def initialize(usuarios:, produtos:, pedidos:, itens_por_pedido:)
    @n_usuarios = usuarios
    @n_produtos = produtos
    @n_pedidos = pedidos
    @itens_por_pedido = itens_por_pedido
    @conn = ActiveRecord::Base.connection.raw_connection
  end

  def call!
    t0 = Time.now
    dropar_indices
    limpar_tabelas
    copiar_usuarios
    copiar_produtos
    copiar_pedidos_itens
    recriar_indices
    agregar_totais
    puts "\nSeed concluído em #{((Time.now - t0) / 60).round(1)} min."
  end

  private

  def dropar_indices
    puts "[drop] índices secundários e FKs..."
    ActiveRecord::Base.connection.execute("ALTER TABLE itens_pedidos DROP CONSTRAINT IF EXISTS fk_rails_0242093e61")
    ActiveRecord::Base.connection.execute("ALTER TABLE itens_pedidos DROP CONSTRAINT IF EXISTS fk_rails_9d7b2b2815")
    ActiveRecord::Base.connection.execute("ALTER TABLE pedidos DROP CONSTRAINT IF EXISTS fk_rails_f6f1f0c038")
    SECONDARY_INDEXES.each do |name|
      ActiveRecord::Base.connection.execute("DROP INDEX IF EXISTS #{name}")
    end
  end

  def limpar_tabelas
    puts "[truncate] tabelas..."
    ActiveRecord::Base.connection.execute("TRUNCATE itens_pedidos, pedidos, produtos, usuarios RESTART IDENTITY")
  end

  def copiar_usuarios
    puts "[copy] usuarios (#{@n_usuarios})"
    done = 0
    agora = Time.now.utc.iso8601
    lote = 50_000

    while done < @n_usuarios
      rows = +""
      qtd = [ lote, @n_usuarios - done ].min
      qtd.times do
        id = done + 1
        nome = "#{NOMES.sample} #{SOBRENOMES.sample}"
        email = "usuario#{id.to_s.rjust(7, "0")}@#{DOMINIOS.sample}"
        cidade = CIDADES.sample
        estado = ESTADOS.sample
        telefone = "5511#{rand(9_000_000_00..9_999_999_99)}"
        tags = TAG_SET.sample(2).to_json
        rows << [ id, nome, email, cidade, estado, telefone, tags, 0, 0, agora, agora ].join("\t") << "\n"
        done += 1
      end
      copy_tsv("usuarios", "id,nome,email,cidade,estado,telefone,tags,pedidos_count,total_gasto,created_at,updated_at", rows)
      puts "  ... #{done}" if (done % 1_000_000).zero?
    end
  end

  def copiar_produtos
    puts "[copy] produtos (#{@n_produtos})"
    done = 0
    agora = Time.now.utc.iso8601
    lote = 50_000

    while done < @n_produtos
      rows = +""
      qtd = [ lote, @n_produtos - done ].min
      qtd.times do
        id = done + 1
        categoria = CATEGORIAS.sample
        nome = "#{PREFIXOS.sample} #{categoria} #{SUFIXOS.sample} ##{id}"
        sku = "SKU-#{id.to_s.rjust(7, "0")}"
        preco = rand(199..19_999)
        estoque = rand(0..5_000)
        rows << [ id, nome, sku, categoria, preco, estoque, agora, agora ].join(",") << "\n"
        done += 1
      end
      copy_csv("produtos", "id,nome,sku,categoria,preco_centavos,estoque,created_at,updated_at", rows)
      puts "  ... #{done}" if (done % 500_000).zero?
    end
  end

  def copiar_pedidos_itens
    puts "[copy] pedidos (#{@n_pedidos}) e itens (#{@n_pedidos * @itens_por_pedido})"
    agora = Time.now.utc.iso8601
    pedido_id = 0
    item_id = 0
    lote = 10_000

    while pedido_id < @n_pedidos
      rows_pedidos = +""
      rows_itens = +""
      qtd = [ lote, @n_pedidos - pedido_id ].min

      qtd.times do
        pedido_id += 1
        criado = Time.at(rand(TEMPO_INICIO..TEMPO_FIM)).utc.iso8601
        status = STATUS.sample
        total = 0

        @itens_por_pedido.times do
          item_id += 1
          produto_id = rand(1..@n_produtos)
          preco = rand(200..19_000)
          qtd_item = rand(1..4)
          total += preco * qtd_item
          rows_itens << [ item_id, pedido_id, produto_id, qtd_item, preco, agora, agora ].join(",") << "\n"
        end

        rows_pedidos << [ pedido_id, rand(1..@n_usuarios), status, total, criado, agora, agora ].join(",") << "\n"
      end

      copy_csv("pedidos", "id,usuario_id,status,total_centavos,criado_em,created_at,updated_at", rows_pedidos)
      copy_csv("itens_pedidos", "id,pedido_id,produto_id,quantidade,preco_unitario_centavos,created_at,updated_at", rows_itens)
      puts "  ... #{pedido_id} pedidos" if (pedido_id % 1_000_000).zero?
    end
  end

  def recriar_indices
    puts "[index] recriando índices e FKs (isso PODE demorar num dataset grande)..."
    c = ActiveRecord::Base.connection

    c.execute("CREATE UNIQUE INDEX index_usuarios_on_email ON usuarios (email)")
    c.execute("CREATE INDEX index_usuarios_on_nome ON usuarios USING gin (nome gin_trgm_ops)")
    c.execute("CREATE INDEX index_usuarios_on_cidade ON usuarios (cidade)")
    c.execute("CREATE INDEX index_usuarios_on_tags ON usuarios USING gin (tags)")

    c.execute("CREATE UNIQUE INDEX index_produtos_on_sku ON produtos (sku)")
    c.execute("CREATE INDEX index_produtos_on_nome ON produtos USING gin (nome gin_trgm_ops)")
    c.execute("CREATE INDEX index_produtos_on_categoria ON produtos (categoria)")

    c.execute("CREATE INDEX index_pedidos_on_status ON pedidos (status)")
    c.execute("CREATE INDEX index_pedidos_on_criado_em ON pedidos (criado_em)")
    c.execute("CREATE INDEX index_pedidos_on_usuario_id ON pedidos (usuario_id)")
    c.execute("CREATE INDEX index_pedidos_on_usuario_id_and_criado_em ON pedidos (usuario_id, criado_em)")
    c.execute("CREATE INDEX index_pedidos_on_usuario_id_cover_total_status ON pedidos (usuario_id) INCLUDE (total_centavos, status)")

    c.execute("CREATE INDEX index_itens_pedidos_on_produto_id ON itens_pedidos (produto_id)")
    c.execute("CREATE INDEX index_itens_pedidos_on_pedido_id ON itens_pedidos (pedido_id)")

    c.execute("ALTER TABLE pedidos ADD CONSTRAINT fk_rails_f6f1f0c038 FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE")
    c.execute("ALTER TABLE itens_pedidos ADD CONSTRAINT fk_rails_9d7b2b2815 FOREIGN KEY (pedido_id) REFERENCES pedidos (id) ON DELETE CASCADE")
    c.execute("ALTER TABLE itens_pedidos ADD CONSTRAINT fk_rails_0242093e61 FOREIGN KEY (produto_id) REFERENCES produtos (id)")
    puts "[index] concluído."
  end

  def agregar_totais
    puts "[agg] agregando contadores por usuario..."
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE usuarios u SET
        pedidos_count = t.pedidos_count,
        total_gasto   = t.total_gasto
      FROM (
        SELECT usuario_id, COUNT(*) AS pedidos_count, COALESCE(SUM(total_centavos), 0) AS total_gasto
        FROM pedidos GROUP BY usuario_id
      ) t
      WHERE u.id = t.usuario_id
    SQL
  end

  def copy_tsv(tabela, colunas, rows)
    @conn.copy_data(%(COPY #{tabela} (#{colunas}) FROM STDIN)) do
      @conn.put_copy_data(rows)
    end
  end

  def copy_csv(tabela, colunas, rows)
    @conn.copy_data(%(COPY #{tabela} (#{colunas}) FROM STDIN WITH (FORMAT csv))) do
      @conn.put_copy_data(rows)
    end
  end
end
