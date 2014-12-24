class CreateJoinTableAyudaestadoDerecho < ActiveRecord::Migration
  def change
    create_join_table :sivel2_sjr_ayudaestado, :sivel2_sjr_derecho,
      table_name: 'sivel2_sjr_ayudaestado_derecho' do |t|
    end
    create_join_table :sivel2_sjr_ayudasjr, :sivel2_sjr_derecho,
      table_name: 'sivel2_sjr_ayudasjr_derecho' do |t|
    end
    create_join_table :sivel2_sjr_motivosjr, :sivel2_sjr_derecho,
      table_name: 'sivel2_sjr_motivosjr_derecho' do |t|
    end
    create_join_table :sivel2_sjr_progestado, :sivel2_sjr_derecho,
      table_name: 'sivel2_sjr_progestado_derecho' do |t|
    end
  end
end
