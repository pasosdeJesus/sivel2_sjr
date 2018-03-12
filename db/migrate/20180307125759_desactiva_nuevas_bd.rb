class DesactivaNuevasBd < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
    UPDATE sivel2_gen_categoria SET fechadeshabilitacion='2018-03-07' 
      WHERE id IN ('916', '917');
    SQL
  end
  def down
    execute <<-SQL
    UPDATE sivel2_gen_categoria SET fechadeshabilitacion=NULL
      WHERE id IN ('916', '917');
    SQL
  end
end
