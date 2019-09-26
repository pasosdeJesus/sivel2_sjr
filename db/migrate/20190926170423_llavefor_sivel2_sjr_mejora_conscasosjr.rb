class LlaveforSivel2SjrMejoraConscasosjr < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      ALTER TABLE sivel2_sjr_casosjr ADD CONSTRAINT vcontacto_lfor
        FOREIGN KEY (id_caso, contacto_id) 
        REFERENCES sivel2_gen_victima(id_caso, id_persona);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE sivel2_sjr_casosjr DROP CONSTRAINT vcontacto_lfor;
    SQL
  end
end
