class IndicesSivel2SjrMejoraConscasosjr < ActiveRecord::Migration[6.0]

  def change
    add_index :sivel2_sjr_respuesta, :fechaatencion,
      name: :indice_sivel2_sjr_respuesta_on_fechaatencion
    add_index :sivel2_sjr_casosjr, :oficina_id,
      name: :indice_sivel2_sjr_casosjr_on_oficina_id
    add_index :sivel2_sjr_casosjr, :asesor,
      name: :indice_sivel2_sjr_casosjr_on_asesor
    add_index :sivel2_sjr_casosjr, [:id_caso, :contacto_id],
      name: :indice_sivel2_sjr_casosjr_on_caso_contacto
    add_index :sivel2_sjr_desplazamiento, :fechaexpulsion,
      name: :indice_sivel2_sjr_desplazamiento_on_fechaexpulsion
    add_index :sivel2_sjr_desplazamiento, :id_llegada,
      name: :indice_sivel2_sjr_desplazamiento_on_id_llegada
    add_index :sivel2_sjr_desplazamiento, :id_caso,
      name: :indice_sivel2_sjr_desplazamiento_on_id_caso
  end

end
