class CompletaTipoind3031 < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      UPDATE cor1440_gen_tipoindicador 
        SET descd1='Contactos',
        descd2='Familiares'
      WHERE id = 30;
      UPDATE cor1440_gen_tipoindicador 
        SET descd1='Contactos únicos',
        descd2='Familiares únicos'
      WHERE id = 31;
    SQL
  end
  def down
  end
end
