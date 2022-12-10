class MasArreglosNombres < ActiveRecord::Migration[7.0]
  include Msip::SqlHelper

  IND = [
    ["indice_sip_ubicacion_sobre_id_caso", "indice_msip_ubicacion_sobre_id_caso"],
    ["sip_persona_buscable_ind", "msip_persona_buscable_ind"],
  ]

  def up
    IND.each do |nomini, nomfin| 
      renombrar_índice_pg(nomini, nomfin)
    end
    renombrar_función_pg("sip_persona_buscable_trigger", 
                         "msip_persona_buscable_trigger")
    execute <<~SQL.squish
      ALTER TRIGGER sip_persona_actualiza_buscable ON msip_persona 
        RENAME TO msip_persona_actualiza_buscable;
    SQL
  end

  def down
    execute <<~SQL.squish
      ALTER TRIGGER msip_persona_actualiza_buscable ON msip_persona 
        RENAME TO sip_persona_actualiza_buscable;
    SQL

    renombrar_función_pg("msip_persona_buscable_trigger", 
                         "sip_persona_buscable_trigger")
    IND.reverse.each do |nomini, nomfin| 
      renombrar_índice_pg(nomfin, nomini)
    end
  end
end
