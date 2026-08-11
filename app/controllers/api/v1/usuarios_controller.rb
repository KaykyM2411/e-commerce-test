module Api
  module V1
    class UsuariosController < ApplicationController
      # GET /api/v1/usuarios
      def index
        result = Usuario.datatable(datatable_params)
        render json: { data: result[:data].map { |usuario| serializar_linha(usuario) }, total_count: result[:total_count] }
      end

      # GET /api/v1/usuarios/:id
      def show
        usuario = Usuario.includes(:pedidos).find(params[:id])
        render json: serializar_linha(usuario).merge(
          pedidos_recentes: usuario.pedidos.order(criado_em: :desc).limit(5).map do |pedido|
            { id: pedido.id, status: pedido.status, total_centavos: pedido.total_centavos }
          end
        )
      end

      private

      def datatable_params
        params.permit(:page, :per_page, :search, filters: {}, range_data: {}, orders: {})
      end

      def serializar_linha(usuario)
        {
          id: usuario.id,
          nome: usuario.nome,
          email: usuario.email,
          cidade: usuario.cidade,
          estado: usuario.estado,
          total_gasto: usuario.total_gasto,
          pedidos_count: usuario.pedidos_count
        }
      end
    end
  end
end
