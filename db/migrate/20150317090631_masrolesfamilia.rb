class Masrolesfamilia < ActiveRecord::Migration
  def up
    execute <<-SQL
INSERT INTO sivel2_sjr_rolfamilia (id, nombre, fechacreacion, created_at) VALUES (9, 'NIETO/A', '2015-03-17', '2015-03-17');
INSERT INTO sivel2_sjr_rolfamilia (id, nombre, fechacreacion, created_at) VALUES (10, 'SOBRINO/A', '2015-03-17', '2015-03-17');
INSERT INTO sivel2_sjr_rolfamilia (id, nombre, fechacreacion, created_at) VALUES (11, 'YERNO/NUERA', '2015-03-17', '2015-03-17');
INSERT INTO sivel2_sjr_rolfamilia (id, nombre, fechacreacion, created_at) VALUES (12, 'HERMANO/A', '2015-03-17', '2015-03-17');
INSERT INTO sivel2_sjr_rolfamilia (id, nombre, fechacreacion, created_at) VALUES (13, 'SUEGRO/A', '2015-03-17', '2015-03-17');
INSERT INTO sivel2_sjr_rolfamilia (id, nombre, fechacreacion, created_at) VALUES (14, 'HERMANASTRO/A', '2015-03-17', '2015-03-17');
INSERT INTO sivel2_sjr_rolfamilia (id, nombre, fechacreacion, created_at) VALUES (15, 'PADRASTRO', '2015-03-17', '2015-03-17');
INSERT INTO sivel2_sjr_rolfamilia (id, nombre, fechacreacion, created_at) VALUES (16, 'MADRASTRA', '2015-03-17', '2015-03-17');
INSERT INTO sivel2_sjr_rolfamilia (id, nombre, fechacreacion, created_at) VALUES (17, 'HIJASTRO/A', '2015-03-17', '2015-03-17');
    SQL
  end
  def down
    execute <<-SQL
DELETE FROM sivel2_sjr_rolfamilia WHERE id>='9' AND id<='17';
    SQL
  end
end
