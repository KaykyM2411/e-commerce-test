require "test_helper"

module Api
  module V1
    class UsuariosControllerTest < ActionDispatch::IntegrationTest
      test "index returns paginated usuarios with total_count" do
        get api_v1_usuarios_url, params: { per_page: 1 }

        assert_response :success
        body = response.parsed_body
        assert_equal Usuario.count, body["total_count"]
        assert_equal 1, body["data"].size
        assert_equal "Ana Silva", body["data"].first["nome"]
      end

      test "index filters by estado" do
        get api_v1_usuarios_url, params: { filters: { estado: "RJ" } }

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["total_count"]
        assert_equal "Carlos Pereira", body["data"].first["nome"]
      end

      test "index searches by nome" do
        get api_v1_usuarios_url, params: { search: "carlos" }

        assert_response :success
        body = response.parsed_body
        assert_equal 1, body["total_count"]
        assert_equal "Carlos Pereira", body["data"].first["nome"]
      end

      test "show returns usuario with recent pedidos" do
        get api_v1_usuario_url(usuarios(:ana))

        assert_response :success
        body = response.parsed_body
        assert_equal "Ana Silva", body["nome"]
        assert_equal 2, body["pedidos_recentes"].size
      end
    end
  end
end
