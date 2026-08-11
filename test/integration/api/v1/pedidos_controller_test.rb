require "test_helper"

module Api
  module V1
    class PedidosControllerTest < ActionDispatch::IntegrationTest
      test "index returns paginated pedidos with total_count" do
        get api_v1_pedidos_url, params: { per_page: 1 }

        assert_response :success
        body = response.parsed_body
        assert_equal Pedido.count, body["total_count"]
        assert_equal 1, body["data"].size
      end

      test "index filters by own status" do
        get api_v1_pedidos_url, params: { filters: { status: "pago" } }

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["total_count"]
        assert_equal "pago", body["data"].first["status"]
      end

      test "index filters by association (usuario.email)" do
        get api_v1_pedidos_url, params: { filters: { "usuario.email" => "carlos@example.com" } }

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["total_count"]
        assert_equal "Carlos Pereira", body["data"].first["usuario"]["nome"]
      end

      test "index orders by association (usuario.nome)" do
        get api_v1_pedidos_url, params: { orders: { "usuario.nome" => "asc" } }

        assert_response :success
        body = response.parsed_body
        assert_equal Pedido.count, body["total_count"]
        assert_equal "Ana Silva", body["data"].first["usuario"]["nome"]
      end

      test "index searches by association (usuario.nome)" do
        get api_v1_pedidos_url, params: { search: "carlos" }

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["total_count"]
        assert_equal "Carlos Pereira", body["data"].first["usuario"]["nome"]
      end

      test "por_usuario returns only that usuario pedidos" do
        get api_v1_usuario_pedidos_url(usuarios(:ana))

        assert_response :success
        body = response.parsed_body
        assert_equal 2, body["total_count"]
        assert body["data"].all? { |pedido| pedido["usuario"]["nome"] == "Ana Silva" }
      end

      test "show returns pedido with items and produto" do
        get api_v1_pedido_url(pedidos(:pago_ana))

        assert_response :success
        body = response.parsed_body
        assert_equal "pago", body["status"]
        assert_equal "Ana Silva", body["usuario"]["nome"]
        assert_equal "Camiseta Polo Algodão", body["itens"].first["produto"]["nome"]
      end

      test "relatorio aggregates pedidos" do
        get api_v1_pedidos_relatorio_url

        assert_response :success
        body = response.parsed_body["relatorio"]
        assert_equal Pedido.count, body["total_pedidos"]
        assert_equal Pedido.sum(:total_centavos), body["total_receita_centavos"]
        assert_equal 3, body["por_status"].keys.size
      end

      test "relatorio respects filters" do
        get api_v1_pedidos_relatorio_url, params: { filters: { status: "pago" } }

        assert_response :success
        body = response.parsed_body["relatorio"]
        assert_equal 1, body["total_pedidos"]
        assert_equal "pago", body["por_status"].keys.first
      end
    end
  end
end
