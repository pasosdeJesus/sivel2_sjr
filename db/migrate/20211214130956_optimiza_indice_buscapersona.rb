class OptimizaIndiceBuscapersona < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION es_unaccent(cadena text) 
      
        RETURNS text
        AS
        $BODY$
          select unaccent($1);
        $BODY$
        LANGUAGE sql
        IMMUTABLE;
      -- IMMUTABLE suponiendo que no se cambiará el locale

      CREATE INDEX sip_persona_nomapnumdoc_ind
        ON sip_persona ((es_unaccent(nombres) || ' ' || es_unaccent(apellidos) || ' ' || COALESCE(numerodocumento::TEXT, '')));
    SQL
  end
  def down
    execute <<-SQL
      DROP INDEX sip_persona_nomapnumdoc_ind;
      DROP FUNCTION IF EXISTS es_unaccent;
    SQL
  end

end
