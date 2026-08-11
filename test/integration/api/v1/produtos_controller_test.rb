require "test_helper"

module Api
  module V1
    class ProdutosControllerTest < ActionDispatch::IntegrationTest
      test "index returns paginated produtos with total_count" do
        get api_v1_produtos_url, params: { per_page: 1 }

        assert_response :success
        body = response.parsed_body
        assert_equal Produto.count, body["total_count"]
        assert_equal 1, body["data"].size
        assert_equal "Camiseta Polo Algodão", body["data"].first["nome"]
      end

      test "index filters by category" do
        get api_v1_produtos_url, params: { filters: { categoria: "Livros" } }

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["total_count"]
        assert_equal "Livro de Ruby Avançado", body["data"].first["nome"]
      end

      test "index filters by range on estoque" do
        get api_v1_produtos_url, params: { range_data: { estoque: [ "100", "200" ] } }

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["total_count"]
        assert_equal "Camiseta Polo Algodão", body["data"].first["nome"]
      end

      test "index orders by preco descending" do
        get api_v1_produtos_url, params: { orders: { preco_centavos: "desc" } }

        assert_response :success
        body = response.parsed_body
        assert_equal Produto.count, body["total_count"]
        assert_equal "Livro de Ruby Avançado", body["data"].first["nome"]
      end

      test "index searches by nome" do
        get api_v1_produtos_url, params: { search: "camiseta" }

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["total_count"]
        assert_equal "Camiseta Polo Algodão", body["data"].first["nome"]
      end

      test "index searches by sku" do
        get api_v1_produtos_url, params: { search: "SKU-0000002" }

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["total_count"]
        assert_equal "Livro de Ruby Avançado", body["data"].first["nome"]
      end

      test "show returns a produto" do
        get api_v1_produto_url(produtos(:camiseta))

        assert_response :success
        body = response.parsed_body
        assert_equal "Camiseta Polo Algodão", body["nome"]
        assert_equal "Vestuário", body["categoria"]
      end
    end
  end
end
