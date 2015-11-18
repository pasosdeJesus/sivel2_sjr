class SuprimeVistaConscaso1 < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW sivel2_gen_conscaso;
      DROP VIEW sivel2_gen_conscaso1;
    SQL
  end
  def down
  end
end
