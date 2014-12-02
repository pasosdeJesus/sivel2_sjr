class RenombraAislasjr < ActiveRecord::Migration
  def change
    rename_table :acreditacion, :sivel2_sjr_acreditacion
    rename_table :actosjr, :sivel2_sjr_actosjr
    rename_table :actualizacionbase, :sivel2_sjr_actualizacionbase
    rename_table :aslegal, :sivel2_sjr_aslegal
    rename_table :aslegal_respuesta, :sivel2_sjr_aslegal_respuesta
    rename_table :ayudaestado, :sivel2_sjr_ayudaestado
    rename_table :ayudaestado_respuesta, :sivel2_sjr_ayudaestado_respuesta
    rename_table :ayudasjr, :sivel2_sjr_ayudasjr
    rename_table :ayudasjr_respuesta, :sivel2_sjr_ayudasjr_respuesta
    rename_table :casosjr, :sivel2_sjr_casosjr
    rename_table :clasifdesp, :sivel2_sjr_clasifdesp
    rename_table :comosupo, :sivel2_sjr_comosupo
    rename_table :declaroante, :sivel2_sjr_declaroante
    rename_table :derecho, :sivel2_sjr_derecho
    rename_table :derecho_respuesta, :sivel2_sjr_derecho_respuesta
    rename_table :desplazamiento, :sivel2_sjr_desplazamiento
    rename_table :etiqueta_usuario, :sivel2_sjr_etiqueta_usuario
    rename_table :idioma, :sivel2_sjr_idioma
    rename_table :inclusion, :sivel2_sjr_inclusion
    rename_table :instanciader, :sivel2_sjr_instanciader
    rename_table :mecanismoder, :sivel2_sjr_mecanismoder
    rename_table :modalidadtierra, :sivel2_sjr_modalidadtierra
    rename_table :motivoconsulta, :sivel2_sjr_motivoconsulta
    rename_table :motivosjr, :sivel2_sjr_motivosjr
    rename_table :motivosjr_respuesta, :sivel2_sjr_motivosjr_respuesta
    rename_table :personadesea, :sivel2_sjr_personadesea
    rename_table :progestado, :sivel2_sjr_progestado
    rename_table :progestado_respuesta, :sivel2_sjr_progestado_respuesta
    rename_table :proteccion, :sivel2_sjr_proteccion
    rename_table :regimensalud, :sivel2_sjr_regimensalud
    rename_table :resagresion, :sivel2_sjr_resagresion
    rename_table :respuesta, :sivel2_sjr_respuesta
    rename_table :rolfamilia, :sivel2_sjr_rolfamilia
    rename_table :statusmigratorio, :sivel2_sjr_statusmigratorio
    rename_table :tipodesp, :sivel2_sjr_tipodesp
    rename_table :victimasjr, :sivel2_sjr_victimasjr
  end
end
