# encoding: UTF-8

require 'sivel2_gen/concerns/models/conscaso'

module Sivel2Sjr
  module Concerns
    module Models
      module Conscaso 
        extend ActiveSupport::Concern

        include Sivel2Gen::Concerns::Models::Conscaso

        included do

        end # included do

        module ClassMethods

          # Refresca vista materializa sivel2_gen_conscaso
          # Si cambia la definición de la vista borre sivel2_gen_conscaso1 y
          # sivel2_gen_conscaso para que esta función las genere modificadas
          def refresca_conscaso
            if !ActiveRecord::Base.connection.table_exists? 'sivel2_gen_conscaso'
              ActiveRecord::Base.connection.execute(
                "CREATE OR REPLACE VIEW sivel2_gen_conscaso1 
        AS SELECT casosjr.id_caso as casoid, 
        ARRAY_TO_STRING(ARRAY(SELECT nombres || ' ' || apellidos 
          FROM sip_persona AS persona
          WHERE persona.id=casosjr.contacto), ', ')
          AS contacto,
        casosjr.fecharec,
        oficina.nombre AS oficina,
        usuario.nusuario,
        caso.fecha AS fecha,
        statusmigratorio.nombre AS statusmigratorio,
        ARRAY_TO_STRING(ARRAY(SELECT fechaatencion 
          FROM sivel2_sjr_respuesta AS respuesta
          WHERE respuesta.id_caso=casosjr.id_caso 
          ORDER BY fechaatencion DESC LIMIT 1), ', ')
          AS ultimafechaatencion,
        caso.memo AS memo
        FROM sivel2_sjr_casosjr AS casosjr, sivel2_gen_caso AS caso, 
          sip_oficina AS oficina, usuario, 
          sivel2_sjr_statusmigratorio AS statusmigratorio
        WHERE casosjr.id_caso = caso.id
          AND oficina.id=casosjr.oficina_id
          AND usuario.id = casosjr.asesor
          AND statusmigratorio.id = casosjr.id_statusmigratorio"
              )
              ActiveRecord::Base.connection.execute(
                "CREATE MATERIALIZED VIEW sivel2_gen_conscaso 
        AS SELECT casoid, contacto, fecharec, oficina, 
          nusuario, fecha, statusmigratorio,
          ultimafechaatencion, memo,
          to_tsvector('spanish', unaccent(casoid || ' ' || contacto || 
            ' ' || replace(cast(fecharec AS varchar), '-', ' ') || 
            ' ' || oficina || ' ' || nusuario || ' ' || 
            replace(cast(fecha AS varchar), '-', ' ') || ' ' ||
            statusmigratorio || ' ' || 
            replace(cast(ultimafechaatencion AS varchar), '-', ' ')
            || ' ' || memo )) as q
        FROM sivel2_gen_conscaso1"
              );
              ActiveRecord::Base.connection.execute(
                "CREATE INDEX busca_conscaso ON sivel2_gen_conscaso USING gin(q);"
              )
            else
              ActiveRecord::Base.connection.execute(
                "REFRESH MATERIALIZED VIEW sivel2_gen_conscaso"
              )
            end
          end # def refresca_conscaso

        end # module ClassMethods

      end
    end
  end
end
