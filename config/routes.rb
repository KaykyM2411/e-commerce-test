Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "pedidos/relatorio", to: "pedidos#relatorio"
      resources :pedidos, only: [ :index, :show ]
      resources :usuarios, only: [ :index, :show ] do
        get :pedidos, to: "pedidos#por_usuario"
      end
      resources :produtos, only: [ :index, :show ]
    end
  end
end
