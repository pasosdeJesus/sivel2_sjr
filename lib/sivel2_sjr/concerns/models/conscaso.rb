# encoding: UTF-8

require 'sivel2_gen/concerns/models/conscaso'

module Sivel2Sjr
  module Concerns
    module Models
      module Conscaso 
        extend ActiveSupport::Concern

        include Sivel2Gen::Concerns::Models::Conscaso

        included do
        
          has_one :casosjr, class_name: 'Sivel2Sjr::Casosjr',
            foreign_key: "id_caso", primary_key: 'caso_id'

          scope :filtro_fecharecini, lambda { |f|
            where('sivel2_gen_conscaso.fecharec >= ?', f)
          }

          scope :filtro_fecharecfin, lambda { |f|
            where('sivel2_gen_conscaso.fecharec <= ?', f)
          }

          scope :filtro_ultimafechaatencionini, lambda { |f|
            where('sivel2_gen_conscaso.ultimafechaatencion >= ?', f)
          }

          scope :filtro_ultimafechaatencionfin, lambda { |f|
            where('sivel2_gen_conscaso.ultimafechaatencion <= ?', f)
          }

          scope :filtro_statusmigratorio_id, lambda { |id|
            where('sivel2_sjr_casosjr.id_statusmigratorio = ?', id).
              joins(:casosjr)
          }

          scope :filtro_nombressp, lambda { |a|
            joins(:casosjr).joins(:persona).
              where('sivel2_sjr_casosjr.contacto = sip_persona.id ' +
                    'AND sip_persona.nombres ILIKE \'%' +
                    ActiveRecord::Base.connection.quote_string(a) + '%\'')
          }

          scope :filtro_apellidossp, lambda { |a|
              joins(:casosjr).joins(:persona).
              where('sivel2_sjr_casosjr.contacto = sip_persona.id ' +
                    'AND sip_persona.apellidos ILIKE \'%' +
                    ActiveRecord::Base.connection.quote_string(a) + '%\'')
          }

          scope :filtro_oficina_id, lambda { |id|
            where('sivel2_sjr_casosjr.oficina_id = ?', id).
              joins(:casosjr)
          }

          scope :ordenar_por, lambda { |campo|
            direction = (campo =~ /desc$/) ? 'desc' : 'asc'
            case campo.to_s
            when /^fechadesc/
              order("sivel2_gen_conscaso.fecha desc")
            when /^fecha/
              order("sivel2_gen_conscaso.fecha asc")
            when /^codigodesc/
              order("sivel2_gen_conscaso.caso_id desc")
            when /^codigo/
              order("sivel2_gen_conscaso.caso_id asc")
            when /^fecharecdesc/
              order("sivel2_gen_conscaso.fecharec desc")
            when /^fecharec/
              order("sivel2_gen_conscaso.fecharec asc")
            when /^ultimafechaatenciondesc/
              order("sivel2_gen_conscaso.ultimafechaatencion desc")
            when /^ultimafechaatencion/
              order("sivel2_gen_conscaso.ultimafechaatencion asc")
            else
              raise(ArgumentError, "Ordenamiento invalido: #{ campo.inspect }")
            end
          }

        end # included do

        module ClassMethods

          # Refresca vista materializa sivel2_gen_conscaso
          # Si cambia la definición de la vista borre sivel2_gen_conscaso1 y
          # sivel2_gen_conscaso para que esta función las genere modificadas
          def refresca_conscaso
            if !ActiveRecord::Base.connection.table_exists? 'sivel2_gen_conscaso'
              ActiveRecord::Base.connection.execute(
                "CREATE OR REPLACE VIEW sivel2_gen_conscaso1 
        AS SELECT casosjr.id_caso as caso_id, 
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
        caso.memo AS memo,
        ARRAY_TO_STRING(ARRAY(SELECT nombres || ' ' || apellidos 
        FROM sip_persona AS persona, 
        sivel2_gen_victima AS victima WHERE persona.id=victima.id_persona 
        AND victima.id_caso=caso.id), ', ')
        AS victimas
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
        AS SELECT caso_id, contacto, fecharec, oficina, 
          nusuario, fecha, statusmigratorio,
          ultimafechaatencion, memo, victimas, 
          to_tsvector('spanish', unaccent(caso_id || ' ' || contacto || 
            ' ' || replace(cast(fecharec AS varchar), '-', ' ') || 
            ' ' || oficina || ' ' || nusuario || ' ' || 
            replace(cast(fecha AS varchar), '-', ' ') || ' ' ||
            statusmigratorio || ' ' || 
            replace(cast(ultimafechaatencion AS varchar), '-', ' ')
            || ' ' || memo || ' ' || victimas)) as q
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
