class ArreglosSivel2Sjr < ActiveRecord::Migration[7.0]
  include Msip::SqlHelper

  IND = [
    ["anexo_pkey", "sivel2_gen_anexo_caso_pkey"],
  ]

  def up
    IND.each do |nomini, nomfin| 
      renombrar_índice_pg(nomini, nomfin)
    end
  end

  def down
    IND.reverse.each do |nomini, nomfin| 
      renombrar_índice_pg(nomfin, nomini)
    end
  end
end
