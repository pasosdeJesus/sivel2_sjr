class CreateJoinTableProgestadoDerecho < ActiveRecord::Migration
  def change
    create_table :sivel2_sjr_progestado_derecho, id:false do |t|
      t.column :progestado_id, :integer
      t.column :derecho_id, :integer
    end
    add_foreign_key :sivel2_sjr_progestado_derecho, :sivel2_sjr_progestado,
      column: :progestado_id
    add_foreign_key :sivel2_sjr_progestado_derecho, :sivel2_sjr_derecho,
      column: :derecho_id
  end
end
