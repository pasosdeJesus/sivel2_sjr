class Eliminterfrontera < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
        UPDATE sivel2_sjr_desplazamiento SET id_clasifdesp = '7' where id_clasifdesp = '5';
        DELETE FROM sivel2_sjr_clasifdesp WHERE id = '5';
    SQL
  end
  def down
    execute <<-SQL
        INSERT INTO sivel2_sjr_clasifdesp 
        (id, nombre, fechacreacion, created_at) VALUES 
        ('5', 'INTER-FRONTERA', '2013-05-24', '2013-05-24');
    SQL
  end
end
