class Usuario < ApplicationRecord
  has_many :pedidos, dependent: :destroy

  searchable_columns :nome, :email
end
