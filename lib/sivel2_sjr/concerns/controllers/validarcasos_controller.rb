# encoding: UTF-8

require_dependency 'sivel2_gen/concerns/controllers/validarcasos_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module ValidarcasosController
        extend ActiveSupport::Concern

        include Sivel2Gen::Concerns::Controllers::ValidarcasosController

        included do
          
          def validacion_estandar(
            casos, titulo, where, atr = [:id_caso, :fecharec],
            encabezado = ['Código', 'Fecha de recepción'])
            res = casos.where(where).select(atr)
            arr = ActiveRecord::Base.connection.select_all(res.to_sql)
            @validaciones << { 
              titulo: titulo,
              encabezado: encabezado,
              cuerpo: arr 
            }
          end

          def filtro_oficina(casos, campo = 'oficina_id')
            if (params[:validarcaso] && params[:validarcaso][:oficina_id] && 
                params[:validarcaso][:oficina_id] != '')
              ofi = params[:validarcaso][:oficina_id].to_i
              casos = casos.where("#{campo} = ?", ofi)
            end
            return casos
          end

          def ini_filtro
            casos = Sivel2Sjr::Casosjr.joins(:caso).all.order(:fecharec)
            casos = filtro_fechas(casos, 'fecharec')
            casos = filtro_oficina(casos)
            return casos
          end

          def valida_sincontacto
            casos = ini_filtro
            casos = casos.
              joins(
                'INNER JOIN sivel2_gen_victima
                 ON sivel2_gen_victima.id=sivel2_sjr_casosjr.contacto').
              joins(
                'INNER JOIN sip_persona
                 ON sip_persona.id=sivel2_gen_victima.id_persona')
            validacion_estandar(
              casos, 
              'Casos sin contacto', 
              "sip_persona.nombres = 'N' AND sip_persona.apellidos = 'N'")
          end

          def valida_sinubicaciones
            casos = ini_filtro
            validacion_estandar(
              casos, 
              'Casos con menos de dos ubicaciones', 
              'id_caso NOT IN 
               (SELECT id_caso FROM 
                (SELECT id_caso, count(id) AS cubi
                 FROM sip_ubicacion GROUP BY 1) AS nubi 
                WHERE cubi>=2)')
          end

          def valida_sinrefugionidesplazamiento
            casos = ini_filtro
            validacion_estandar(
              casos, 
              'Casos sin desplazamiento y sin refugio', 
              'id_caso NOT IN 
               (SELECT id_caso FROM 
                (SELECT id_caso, count(id) AS cdes
                 FROM sivel2_sjr_desplazamiento GROUP BY 1) AS ndesp
                WHERE cdes>0)
               AND sivel2_sjr_casosjr.id_salida IS NULL
               AND sivel2_sjr_casosjr.id_llegada IS NULL
              ')
          end

          def valida_sinrespuesta
            casos = ini_filtro
            validacion_estandar(
              casos, 
              'Casos sin respuesta/seguimiento', 
              'id_caso NOT IN 
               (SELECT id_caso FROM 
                (SELECT id_caso, count(id) AS cresp
                 FROM sivel2_sjr_respuesta GROUP BY 1) AS nresp
                WHERE cresp>0)
              ')
          end

          def valida_sinfechadesp
            casos = ini_filtro
            validacion_estandar(
              casos, 
              'Casos con fecha de desplazamiento igual a fecha de recepción', 
              'sivel2_gen_caso.fecha = fecharec'
            )
          end

          def valida_sindocid
            casos = ini_filtro
            casos = casos.
              joins(
                'INNER JOIN sivel2_gen_victima
                 ON sivel2_gen_victima.id=sivel2_sjr_casosjr.contacto').
              joins(
                'INNER JOIN sip_persona
                 ON sip_persona.id=sivel2_gen_victima.id_persona')
            validacion_estandar(
              casos, 
              'Casos con contacto sin documento de identidad', 
              'sip_persona.numerodocumento IS NULL 
               OR sip_persona.tdocumento_id IS NULL'
            )
          end


          def valida_sinayudasjr
            casos = ini_filtro
            casos = casos.joins('JOIN sivel2_sjr_respuesta ON
              sivel2_sjr_respuesta.id_caso=sivel2_sjr_casosjr.id_caso')
            validacion_estandar(
              casos, 
              'Casos con respuesta pero sin ayuda/asesoria del SJR',
              'sivel2_sjr_respuesta.id NOT IN 
               (SELECT id_respuesta FROM sivel2_sjr_ayudasjr_respuesta)
               AND sivel2_sjr_respuesta.id NOT IN 
               (SELECT id_respuesta FROM sivel2_sjr_aslegal_respuesta)
              '
            )
          end

          def validar_sivel2_sjr
            valida_sincontacto
            valida_sinubicaciones
            valida_sinrefugionidesplazamiento
            valida_sinrespuesta
            valida_sinfechadesp
            valida_sindocid
            valida_sinayudasjr
          end

          def validar_interno
            @rango_fechas = 'Fecha de recepción'
            validar_sivel2_sjr
           #valida_sinderechovulnerado
            validar_sivel2_gen
          end # def validar_interno
         
          def validarcasos_params
            params.require(:validarcaso).permit(
              :fechafin,
              :fechaini,
              :oficina
            )
          end

        end # included

      end
    end
  end
end

