class RegionsjrAOficina < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE sivel2_sjr_casosjr
        RENAME COLUMN id_regionsjr TO oficina_id;
    SQL
  end
  
  def down
    execute <<-SQL
      ALTER TABLE sivel2_sjr_casosjr
        RENAME COLUMN oficina_id TO id_regionsjr;
    SQL
  end
end
