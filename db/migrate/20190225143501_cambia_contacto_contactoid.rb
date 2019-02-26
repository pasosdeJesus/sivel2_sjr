class CambiaContactoContactoid < ActiveRecord::Migration[5.2]
  def change
    rename_column :sivel2_sjr_casosjr, :contacto, :contacto_id
    execute <<-SQL
      DROP VIEW IF EXISTS sivel2_gen_conscaso1 CASCADE;
    SQL
  end
end
