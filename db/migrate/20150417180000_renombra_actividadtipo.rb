class RenombraActividadtipo < ActiveRecord::Migration
  def up
	  execute <<-SQL 
			ALTER SEQUENCE actividadtipos_id_seq 
        RENAME TO cor1440_gen_actividadtipo_id_seq;
		SQL
	  execute <<-SQL 
        ALTER TABLE actividadtipos RENAME TO cor1440_gen_actividadtipo;
    SQL
		execute <<-SQL 
      ALTER TABLE cor1440_gen_actividadtipo 
        RENAME CONSTRAINT actividadtipos_pkey TO cor1440_gen_actividadtipo_pkey; 
		SQL
  end

  def down
		execute <<-SQL 
      ALTER TABLE cor1440_gen_actividadtipo 
        RENAME CONSTRAINT cor1440_gen_actividadtipo_pkey TO actividadtipos_pkey
		SQL
	  execute <<-SQL 
        ALTER TABLE cor1440_gen_actividadtipo RENAME TO actividadtipos;
    SQL
	  execute <<-SQL 
			ALTER SEQUENCE cor1440_gen_actividadtipo_id_seq 
        RENAME TO actividadtipos_id_seq 
		SQL

  end
end
