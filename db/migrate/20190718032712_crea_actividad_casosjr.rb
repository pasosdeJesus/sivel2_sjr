class CreaActividadCasosjr < ActiveRecord::Migration[6.0]
  def change
      create_table :sivel2_sjr_actividad_casosjr do |t|
        t.integer :actividad_id
        t.integer :casosjr_id
      end
      add_foreign_key :sivel2_sjr_actividad_casosjr, :cor1440_gen_actividad, 
        column: :actividad_id
      add_foreign_key :sivel2_sjr_actividad_casosjr, :sivel2_sjr_casosjr, 
        column: :casosjr_id, primary_key: :id_caso
  end
end
