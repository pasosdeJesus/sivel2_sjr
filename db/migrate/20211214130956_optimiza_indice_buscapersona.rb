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

      ALTER TABLE sip_persona ADD COLUMN buscable tsvector;

      -- No podemos usar tsvector_update_trigger porque reciben
      -- nombres de columas y no permite poner unaccent y
      -- los tsvector quedan con los caracteres del español
      -- que no permite busqueda aproximada n->ñ, a->á, etc.

      CREATE FUNCTION sip_persona_buscable_trigger() RETURNS trigger AS $$
      begin
        new.buscable := to_tsvector('spanish', 
          es_unaccent(new.nombres) ||
          ' ' || es_unaccent(new.apellidos) || 
          ' ' || COALESCE(new.numerodocumento::TEXT, ''));
        return new;
      end
      $$ LANGUAGE plpgsql;


      CREATE TRIGGER sip_persona_actualiza_buscable BEFORE INSERT OR UPDATE
        ON sip_persona FOR EACH ROW EXECUTE PROCEDURE
        sip_persona_buscable_trigger()
      ;

      CREATE INDEX sip_persona_buscable_ind
        ON sip_persona USING GIN ((buscable));

      -- Lanzamos trigger
      UPDATE sip_persona SET nombres=nombres, 
        apellidos=apellidos, numerodocumento=numerodocumento;

    SQL
  end
  def down
    execute <<-SQL
      DROP INDEX IF EXISTS sip_persona_buscable_ind;
      DROP TRIGGER IF EXISTS sip_persona_actualiza_buscable ON sip_persona;
      DROP FUNCTION IF EXISTS sip_persona_buscable_trigger;
      ALTER TABLE sip_persona DROP COLUMN buscable;
      DROP FUNCTION IF EXISTS es_unaccent;
    SQL
  end

end
