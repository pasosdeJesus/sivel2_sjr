class CreateJoinTableAyudasjrDerecho < ActiveRecord::Migration[4.2]
  def change
    create_table :sivel2_sjr_ayudasjr_derecho, id:false do |t|
      t.column :ayudasjr_id, :integer
      t.column :derecho_id, :integer
    end
    add_foreign_key :sivel2_sjr_ayudasjr_derecho, :sivel2_sjr_ayudasjr,
      column: :ayudasjr_id
    add_foreign_key :sivel2_sjr_ayudasjr_derecho, :sivel2_sjr_derecho,
      column: :derecho_id
  end
end
