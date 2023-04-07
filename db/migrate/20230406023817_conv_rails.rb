class ConvRails < ActiveRecord::Migration[7.0]
  def change
    rename_column :sivel2_sjr_casosjr, :id_caso, :caso_id
    rename_column :sivel2_sjr_casosjr, :id_statusmigratorio, :estatusmigratorio_id
    rename_column :sivel2_sjr_casosjr, :id_proteccion, :proteccion_id
    rename_column :sivel2_sjr_casosjr, :id_salida, :salida_id
    rename_column :sivel2_sjr_casosjr, :id_llegada, :llegada_id
    
    rename_column :sivel2_sjr_desplazamiento, :id_caso, :caso_id
    rename_column :sivel2_sjr_desplazamiento, :id_clasifdesp, :clasifdesp_id
    rename_column :sivel2_sjr_desplazamiento, :id_tipodesp, :tipodesp_id
    rename_column :sivel2_sjr_desplazamiento, :id_declaroante, :declaroante_id
    rename_column :sivel2_sjr_desplazamiento, :id_inclusion, :inclusion_id
    rename_column :sivel2_sjr_desplazamiento, :id_acreditacion, :acreditacion_id
    rename_column :sivel2_sjr_desplazamiento, :id_modalidadtierra, :modalidadtierra_id

    rename_column :sivel2_sjr_aslegal_respuesta, :id_respuesta, :respuesta_id
    rename_column :sivel2_sjr_aslegal_respuesta, :id_aslegal, :aslegal_id

    rename_column :sivel2_sjr_respuesta, :id_caso, :caso_id
    rename_column :sivel2_sjr_respuesta, :id_personadesea, :personadesea_id

    rename_column :sivel2_sjr_actosjr, :id_acto, :acto_id
    
    rename_column :sivel2_sjr_aspsicosocial_respuesta, 
      :id_aspsicosocial, :aspsicosocial_id
    rename_column :sivel2_sjr_aspsicosocial_respuesta, 
      :id_respuesta, :respuesta_id

    rename_column :sivel2_sjr_ayudaestado_respuesta, 
      :id_ayudaestado, :ayudaestado_id
    rename_column :sivel2_sjr_ayudaestado_respuesta, 
      :id_respuesta, :respuesta_id

    rename_column :sivel2_sjr_ayudasjr_respuesta, 
      :id_ayudasjr, :ayudasjr_id
    rename_column :sivel2_sjr_ayudasjr_respuesta, 
      :id_respuesta, :respuesta_id

    rename_column :sivel2_sjr_derecho_respuesta, 
      :id_derecho, :derecho_id
    rename_column :sivel2_sjr_derecho_respuesta, 
      :id_respuesta, :respuesta_id

    rename_column :sivel2_sjr_motivosjr_respuesta, 
      :id_motivosjr, :motivosjr_id
    rename_column :sivel2_sjr_motivosjr_respuesta, 
      :id_respuesta, :respuesta_id

    rename_column :sivel2_sjr_progestado_respuesta, 
      :id_progestado, :progestado_id
    rename_column :sivel2_sjr_progestado_respuesta, 
      :id_respuesta, :respuesta_id

    rename_column :sivel2_sjr_victimasjr, :id_estadocivil, :estadocivil_id
    rename_column :sivel2_sjr_victimasjr, :id_rolfamilia, :rolfamilia_id
    rename_column :sivel2_sjr_victimasjr, :id_maternidad, :maternidad_id
    rename_column :sivel2_sjr_victimasjr, :id_actividadoficio, :actividadoficio_id
    rename_column :sivel2_sjr_victimasjr, :id_escolaridad, :escolaridad_id
    rename_column :sivel2_sjr_victimasjr, :id_departamento, :departamento_id
    rename_column :sivel2_sjr_victimasjr, :id_municipio, :municipio_id
    rename_column :sivel2_sjr_victimasjr, :id_regimensalud, :regimensalud_id
    rename_column :sivel2_sjr_victimasjr, :id_victima, :victima_id
  end
end
