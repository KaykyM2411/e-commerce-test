module Api
  module V1
    class PedidosController < ApplicationController
      # GET /api/v1/pedidos
      def index
        result = Pedido.datatable(datatable_params, allowed_paths: [ :usuario ], includes: [ :usuario ])
        render json: { data: result[:data].map { |pedido| serializar_linha(pedido) }, total_count: result[:total_count] }
      end

      # GET /api/v1/pedidos/:id
      def show
        pedido = Pedido
                 .includes(:usuario, itens_pedidos: :produto)
                 .find(params[:id])
        render json: serializar_pedido_completo(pedido)
      end

      # GET /api/v1/usuarios/:usuario_id/pedidos
      def por_usuario
        usuario = Usuario.find(params[:usuario_id])
        consulta = params.except(:usuario_id).permit(
          :page, :per_page, :search, filters: {}, range_data: {}, orders: {}
        ).merge(filters: { "usuario_id" => usuario.id })
        result = Pedido.datatable(consulta, includes: [ :usuario ])
        render json: { data: result[:data].map { |pedido| serializar_linha(pedido) }, total_count: result[:total_count] }
      end

      # GET /api/v1/pedidos/relatorio
      def relatorio
        consulta = params.permit(:search, filters: {}).to_h
        relacao = Pedido.datatable_relation(consulta, allowed_paths: [ :usuario ])

        total_pedidos, total_receita_centavos, media_ticket =
          relacao.pick(
            Arel.sql("COUNT(*)"),
            Arel.sql("SUM(total_centavos)"),
            Arel.sql("AVG(total_centavos)")
          )

        render json: {
          relatorio: {
            total_pedidos: total_pedidos,
            total_receita_centavos: total_receita_centavos,
            media_ticket: media_ticket,
            por_status: relacao.group(:status).count
          }
        }
      end

      private

      def datatable_params
        params.permit(:page, :per_page, :search, filters: {}, range_data: {}, orders: {})
      end

      def serializar_linha(pedido)
        {
          id: pedido.id,
          status: pedido.status,
          total_centavos: pedido.total_centavos,
          criado_em: pedido.criado_em,
          usuario: nome_usuario(pedido.usuario)
        }
      end

      def nome_usuario(usuario)
        { id: usuario.id, nome: usuario.nome, email: usuario.email, cidade: usuario.cidade }
      end

      def serializar_pedido_completo(pedido)
        {
          id: pedido.id,
          status: pedido.status,
          total_centavos: pedido.total_centavos,
          criado_em: pedido.criado_em,
          usuario: {
            id: pedido.usuario.id,
            nome: pedido.usuario.nome,
            email: pedido.usuario.email,
            cidade: pedido.usuario.cidade,
            telefone: pedido.usuario.telefone
          },
          itens: pedido.itens_pedidos.map do |item|
            {
              quantidade: item.quantidade,
              preco_unitario_centavos: item.preco_unitario_centavos,
              produto: {
                id: item.produto.id,
                nome: item.produto.nome,
                sku: item.produto.sku,
                categoria: item.produto.categoria
              }
            }
          end
        }
      end
    end
  end
end
