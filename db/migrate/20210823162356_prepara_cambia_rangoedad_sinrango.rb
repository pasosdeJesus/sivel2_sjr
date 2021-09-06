class PreparaCambiaRangoedadSinrango < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW sivel2_gen_consexpcaso;
    SQL
  end
  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW sivel2_gen_consexpcaso;
    SQL
  end
end
