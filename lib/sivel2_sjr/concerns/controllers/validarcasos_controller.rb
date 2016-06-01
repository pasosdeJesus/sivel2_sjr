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
            casos = casos.clone.
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

          def validar_interno
            @rango_fechas = 'Fecha de recepción'
            #byebug
            valida_sincontacto
            valida_sinmemo
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

