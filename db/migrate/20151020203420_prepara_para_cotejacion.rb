class PreparaParaCotejacion < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS sivel2_gen_conscaso;
    SQL
    execute <<-SQL
      DROP VIEW IF EXISTS sivel2_gen_conscaso1;
    SQL
    execute <<-SQL
      DROP VIEW IF EXISTS cons;
    SQL
  end
  def down
    execute <<-SQL
      CREATE VIEW sivel2_gen_conscaso1 AS
       SELECT casosjr.id_caso AS caso_id,
          array_to_string(ARRAY( SELECT (((persona.nombres)::text || ' '::text) || (persona.apellidos)::text)
                 FROM sip_persona persona
                WHERE (persona.id = casosjr.contacto)), ', '::text) AS contacto,
          casosjr.fecharec,
          oficina.nombre AS oficina,
          usuario.nusuario,
          caso.fecha,
          statusmigratorio.nombre AS statusmigratorio,
          array_to_string(ARRAY( SELECT respuesta.fechaatencion
                 FROM sivel2_sjr_respuesta respuesta
                WHERE (respuesta.id_caso = casosjr.id_caso)
                ORDER BY respuesta.fechaatencion DESC
               LIMIT 1), ', '::text) AS ultimafechaatencion,
          caso.memo,
          array_to_string(ARRAY( SELECT (((persona.nombres)::text || ' '::text) || (persona.apellidos)::text)
                 FROM sip_persona persona,
                  sivel2_gen_victima victima
                WHERE ((persona.id = victima.id_persona) AND (victima.id_caso = caso.id))), ', '::text) AS victimas
         FROM sivel2_sjr_casosjr casosjr,
          sivel2_gen_caso caso,
          sip_oficina oficina,
          usuario,
          sivel2_sjr_statusmigratorio statusmigratorio
        WHERE ((((casosjr.id_caso = caso.id) AND (oficina.id = casosjr.oficina_id)) AND (usuario.id = casosjr.asesor)) AND (statusmigratorio.id = casosjr.id_statusmigratorio));
    SQL
    execute <<-SQL
      CREATE MATERIALIZED VIEW sivel2_gen_conscaso AS
       SELECT sivel2_gen_conscaso1.caso_id,
          sivel2_gen_conscaso1.contacto,
          sivel2_gen_conscaso1.fecharec,
          sivel2_gen_conscaso1.oficina,
          sivel2_gen_conscaso1.nusuario,
          sivel2_gen_conscaso1.fecha,
          sivel2_gen_conscaso1.statusmigratorio,
          sivel2_gen_conscaso1.ultimafechaatencion,
          sivel2_gen_conscaso1.memo,
          sivel2_gen_conscaso1.victimas,
          to_tsvector('spanish'::regconfig, unaccent(((((((((((((((((((sivel2_gen_conscaso1.caso_id || ' '::text) || sivel2_gen_conscaso1.contacto) || ' '::text) || replace(((sivel2_gen_conscaso1.fecharec)::character varying)::text, '-'::text, ' '::text)) || ' '::text) || (sivel2_gen_conscaso1.oficina)::text) || ' '::text) || (sivel2_gen_conscaso1.nusuario)::text) || ' '::text) || replace(((sivel2_gen_conscaso1.fecha)::character varying)::text, '-'::text, ' '::text)) || ' '::text) || (sivel2_gen_conscaso1.statusmigratorio)::text) || ' '::text) || replace(((sivel2_gen_conscaso1.ultimafechaatencion)::character varying)::text, '-'::text, ' '::text)) || ' '::text) || sivel2_gen_conscaso1.memo) || ' '::text) || sivel2_gen_conscaso1.victimas))) AS q
         FROM sivel2_gen_conscaso1;
    SQL
  end
end
