class CreateJoinTableAyudaestadoDerecho < ActiveRecord::Migration[4.2]
  def change
    create_table :sivel2_sjr_ayudaestado_derecho, id:false do |t|
      t.column :ayudaestado_id, :integer
      t.column :derecho_id, :integer
    end
    add_foreign_key :sivel2_sjr_ayudaestado_derecho, :sivel2_sjr_ayudaestado,
      column: :ayudaestado_id
    add_foreign_key :sivel2_sjr_ayudaestado_derecho, :sivel2_sjr_derecho,
      column: :derecho_id
  end
end
