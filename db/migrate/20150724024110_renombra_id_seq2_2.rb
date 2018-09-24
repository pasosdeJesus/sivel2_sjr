class RenombraIdSeq22 < ActiveRecord::Migration[4.2]
  @@tablas = [
    'acreditacion',  
    'ayudaestado', 
    'clasifdesp',
    'inclusion',
    'modalidadtierra',
    'declaroante',
    'derecho',
    'motivosjr',
    'personadesea',
    'progestado',
  ]
  def up
    conexion = Sivel2Sjr::Casosjr.connection()
    @@tablas.each do |t|
      Sip::renombra_secuencia(conexion, "#{t}_seq", "sivel2_sjr_#{t}_id_seq")
    end
  end

  def down
    conexion = Sivel2Sjr::Casosjr.connection()
    @@tablas.each do |t|
      Sip::renombra_secuencia(conexion, "sivel2_sjr_#{t}_id_seq", "#{t}_seq")
    end
  end
end
