class AddPedidosReportCoveringIndex < ActiveRecord::Migration[8.0]
  def change
    add_index :pedidos,
              :usuario_id,
              name: "index_pedidos_on_usuario_id_cover_total_status",
              include: [ :total_centavos, :status ]
  end
end
