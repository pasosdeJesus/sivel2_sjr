class RenombraIdSeq22 < ActiveRecord::Migration
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
    @@tablas.each do |t|
        execute <<-SQL
            ALTER SEQUENCE #{t + '_seq'}
                RENAME TO sivel2_sjr_#{t + '_id_seq'};
        SQL
    end
  end

  def down
    @@tablas.each do |t|
        execute <<-SQL
            ALTER SEQUENCE sivel2_sjr_#{t}_id_seq 
                RENAME TO #{t}_seq;
        SQL
    end
  end
end
