class Mastiposdesp < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
INSERT INTO sivel2_sjr_tipodesp (id, nombre, fechacreacion, created_at) VALUES (4, 'RURAL-URBANO', '2015-03-17', '2015-03-17');
INSERT INTO sivel2_sjr_tipodesp (id, nombre, fechacreacion, created_at) VALUES (5, 'URBANO-RURAL', '2015-03-17', '2015-03-17');
    SQL
  end
  def down
    execute <<-SQL
DELETE FROM sivel2_sjr_tipodesp WHERE id IN ('4', '5');
    SQL
  end
end
