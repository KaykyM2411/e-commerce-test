module Api
  module V1
    class ProdutosController < ApplicationController
      # GET /api/v1/produtos
      def index
        result = Produto.datatable(datatable_params)
        render json: { data: result[:data].map { |produto| serializar_linha(produto) }, total_count: result[:total_count] }
      end

      # GET /api/v1/produtos/:id
      def show
        produto = Produto.find(params[:id])
        render json: serializar_linha(produto)
      end

      private

      def datatable_params
        params.permit(:page, :per_page, :search, filters: {}, range_data: {}, orders: {})
      end

      def serializar_linha(produto)
        {
          id: produto.id,
          nome: produto.nome,
          sku: produto.sku,
          categoria: produto.categoria,
          preco_centavos: produto.preco_centavos,
          estoque: produto.estoque
        }
      end
    end
  end
end
