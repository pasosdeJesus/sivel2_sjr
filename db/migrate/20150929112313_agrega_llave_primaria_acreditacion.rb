class AgregaLlavePrimariaAcreditacion < ActiveRecord::Migration
  def up
    execute <<-SQL
    ALTER TABLE sivel2_sjr_acreditacion ADD PRIMARY KEY (id);
    SQL
  end
  def down
    execute <<-SQL
    ALTER TABLE sivel2_sjr_acreditacion DROP CONSTRAINT sivel2_sjr_acreditacion_pkey;
    SQL
  end
end
