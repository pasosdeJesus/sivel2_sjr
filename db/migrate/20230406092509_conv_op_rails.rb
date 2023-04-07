class ConvOpRails < ActiveRecord::Migration[7.0]
  def up
    if Sivel2Sjr::Casosjr.columns.map(&:name).include?(:idioma_id)
      rename_column :sivel2_sjr_casosjr, :id_idioma, :idioma_id
    end
    if table_exists?(:sivel2_gen_anexo_victima) && 
        Sivel2Gen::AnexoVictima.columns.map(&:name).include?(:id_anexo)
      rename_column :sivel2_gen_anexo_victima, :id_anexo, :anexo_id
      rename_column :sivel2_gen_anexo_victima, :id_victima, :victima_id
    end
    if table_exists?(:sivel2_sjr_refugio)
      rename_column :sivel2_sjr_refugio, :id_caso, :caso_id
      rename_column :sivel2_sjr_refugio, :id_salida, :salida_id
      rename_column :sivel2_sjr_refugio, :id_llegada, :llegada_id
      rename_column :sivel2_sjr_refugio, :id_causaref, :causaref_id
    end
    if Sivel2Sjr::Desplazamiento.columns.map(&:name).include?(:id_expulsion)
      rename_column :sivel2_sjr_desplazamiento, :id_expulsion, :expulsion_id
      rename_column :sivel2_sjr_desplazamiento, :id_llegada, :llegada_id
    end
    if Sivel2Sjr::Victimasjr.columns.map(&:name).include?(:id_pais)
      rename_column :sivel2_sjr_victimasjr, :id_pais, :pais_id
    end
  end
  def down
    if Sivel2Sjr::Casosjr.columns.map(&:name).include?(:id_idioma)
      rename_column :sivel2_sjr_casosjr, :idioma_id, :id_idioma
    end
    if table_exists?(:sivel2_gen_anexo_victima)
      rename_column :sivel2_gen_anexo_victima, :anexo_id, :id_anexo
      rename_column :sivel2_gen_anexo_victima, :victima_id, :id_victima
    end
    if table_exists?(:sivel2_sjr_refugio)
      rename_column :sivel2_sjr_refugio, :caso_id, :id_caso
      rename_column :sivel2_sjr_refugio, :salida_id, :id_salida
      rename_column :sivel2_sjr_refugio, :llegada_id, :id_llegada
      rename_column :sivel2_sjr_refugio, :causaref_id, :id_causaref
    end
    if Sivel2Sjr::Desplazamiento.columns.map(&:name).include?(:expulsion_id)
      rename_column :sivel2_sjr_desplazamiento, :expulsion_id, :id_expulsion
      rename_column :sivel2_sjr_desplazamiento, :llegada_id, :id_llegada
    end
    if Sivel2Sjr::Victimasjr.columns.map(&:name).include?(:pais_id)
      rename_column :sivel2_sjr_victimasjr, :pais_id, :id_pais
    end

  end

end
