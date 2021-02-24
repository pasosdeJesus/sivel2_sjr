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

          scope :filtro_atenciones_fechaini, lambda { |fecha|
            where('caso_id IN (SELECT casosjr_id FROM 
              sivel2_sjr_actividad_casosjr JOIN cor1440_gen_actividad
              ON sivel2_sjr_actividad_casosjr.actividad_id =
                cor1440_gen_actividad.id
              WHERE
                cor1440_gen_actividad.fecha >= ?)', fecha)
          }

          scope :filtro_atenciones_fechafin, lambda { |fecha|
            where('caso_id IN (SELECT casosjr_id FROM 
              sivel2_sjr_actividad_casosjr JOIN cor1440_gen_actividad
              ON sivel2_sjr_actividad_casosjr.actividad_id =
                cor1440_gen_actividad.id
              WHERE
                cor1440_gen_actividad.fecha <= ?)', fecha)
          }

          scope :filtro_departamento_id, lambda { |id|
            where('caso_id IN (SELECT id_caso
                    FROM public.sip_ubicacion
                    WHERE sip_ubicacion.id_departamento = ?)', id)
          }
          scope :filtro_fecharecini, lambda { |f|
            where('sivel2_gen_conscaso.fecharec >= ?', f)
          }

          scope :filtro_fecharecfin, lambda { |f|
            where('sivel2_gen_conscaso.fecharec <= ?', f)
          }

          scope :filtro_nusuario, lambda { |n|
            where('sivel2_gen_conscaso.nusuario = ?', n)
          }

          scope :filtro_ultimaatencion_fechaini, lambda { |f|
            where('sivel2_gen_conscaso.ultimaatencion_fecha >= ?', f)
          }

          scope :filtro_ultimaatencion_fechafin, lambda { |f|
            where('sivel2_gen_conscaso.ultimaatencion_fecha <= ?', f)
          }

          scope :filtro_statusmigratorio_id, lambda { |id|
            where('sivel2_sjr_casosjr.id_statusmigratorio = ?', id).
              joins(:casosjr)
          }

          scope :filtro_nombressp, lambda { |a|
            joins(:casosjr).joins(:persona).
              where('sivel2_sjr_casosjr.contacto_id = sip_persona.id ' +
                    'AND sip_persona.nombres ILIKE \'%' +
                    ActiveRecord::Base.connection.quote_string(a) + '%\'')
          }

          scope :filtro_apellidossp, lambda { |a|
              joins(:casosjr).joins(:persona).
              where('sivel2_sjr_casosjr.contacto_id = sip_persona.id ' +
                    'AND sip_persona.apellidos ILIKE \'%' +
                    ActiveRecord::Base.connection.quote_string(a) + '%\'')
          }

          scope :filtro_oficina_id, lambda { |id|
            where('sivel2_sjr_casosjr.oficina_id = ?', id).
              joins(:casosjr)
          }

          scope :ordenar_por, lambda { |campo|
            critord = ""
            case campo.to_s
            when /^codigo/
              critord ="sivel2_gen_conscaso.caso_id asc"
            when /^codigodesc/
              critord = "sivel2_gen_conscaso.caso_id desc"
            when /^fecharec/
              critord = "sivel2_gen_conscaso.fecharec desc"
            when /^fecharecasc/
              critord = "sivel2_gen_conscaso.fecharec asc"
            when /^fecha/
              critord = "sivel2_gen_conscaso.fecha asc"
            when /^fechadesc/
              critord = "sivel2_gen_conscaso.fecha desc"
            when /^ubicacion/
              critord = "sivel2_gen_conscaso.ubicaciones asc"
            when /^ubicaciondesc/
              critord = "sivel2_gen_conscaso.ubicaciones desc"
            when /^ultimaatencion_fecha/
              critord = "sivel2_gen_conscaso.ultimaatencion_fecha desc"
            when /^ultimaatencion_fechaasc/
              critord = "sivel2_gen_conscaso.ultimaatencion_fecha asc"
            else
              raise(ArgumentError, "Ordenamiento invalido: #{ campo.inspect }")
            end
            order(critord + ', sivel2_gen_conscaso.caso_id')
          }

        end # included do

        module ClassMethods

          # Refresca vista materializa sivel2_gen_conscaso
          # Si cambia la definición de la vista borre sivel2_gen_conscaso1 y
          # sivel2_gen_conscaso para que esta función las genere modificadas
          def refresca_conscaso
            if !ActiveRecord::Base.connection.data_source_exists? 'sivel2_gen_conscaso'
              ActiveRecord::Base.connection.execute(
                "CREATE OR REPLACE VIEW sivel2_gen_conscaso1 
        AS SELECT casosjr.id_caso as caso_id, 
        ARRAY_TO_STRING(ARRAY(SELECT nombres || ' ' || apellidos 
          FROM public.sip_persona AS persona
          WHERE persona.id=casosjr.contacto_id), ', ')
          AS contacto,
        casosjr.fecharec,
        oficina.nombre AS oficina,
        usuario.nusuario,
        caso.fecha AS fecha,
        statusmigratorio.nombre AS statusmigratorio,
        ARRAY_TO_STRING(ARRAY(SELECT fechaatencion 
          FROM public.sivel2_sjr_respuesta AS respuesta
          WHERE respuesta.id_caso=casosjr.id_caso 
          ORDER BY fechaatencion DESC LIMIT 1), ', ')
          AS ultimaatencion_fecha,
        caso.memo AS memo,
        ARRAY_TO_STRING(ARRAY(SELECT nombres || ' ' || apellidos 
        FROM public.sip_persona AS persona, 
        public.sivel2_gen_victima AS victima WHERE persona.id=victima.id_persona 
        AND victima.id_caso=caso.id), ', ')
        AS victimas
        FROM public.sivel2_sjr_casosjr AS casosjr
        JOIN sivel2_gen_caso AS caso ON casosjr.id_caso = caso.id
        JOIN sip_oficina AS oficina ON oficina.id=casosjr.oficina_id
        JOIN usuario ON usuario.id = casosjr.asesor
        LEFT JOIN sivel2_sjr_statusmigratorio AS statusmigratorio ON
          statusmigratorio.id = casosjr.id_statusmigratorio"
              )
              ActiveRecord::Base.connection.execute(
                "CREATE MATERIALIZED VIEW sivel2_gen_conscaso 
        AS SELECT caso_id, contacto, fecharec, oficina, 
          nusuario, fecha, statusmigratorio,
          ultimaatencion_fecha, memo, victimas, 
          to_tsvector('spanish', unaccent(caso_id || ' ' || contacto || 
            ' ' || replace(cast(fecharec AS varchar), '-', ' ') || 
            ' ' || oficina || ' ' || nusuario || ' ' || 
            replace(cast(fecha AS varchar), '-', ' ') || ' ' ||
            statusmigratorio || ' ' || 
            replace(cast(ultimaatencion_fecha AS varchar), '-', ' ')
            || ' ' || memo || ' ' || victimas)) as q
        FROM public.sivel2_gen_conscaso1"
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
