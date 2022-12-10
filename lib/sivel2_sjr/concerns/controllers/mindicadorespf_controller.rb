require_dependency 'cor1440_gen/concerns/controllers/mindicadorespf_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module MindicadorespfController
        extend ActiveSupport::Concern


        included do
          include Cor1440Gen::Concerns::Controllers::MindicadorespfController

          # Calcula beneficiarios diferentes con el sexo `sexo` no desagregados
          # antes de la fecha `ffin` en casos beneficiarios de actividades 
          # con ids `idacs`.  
          # Retorna ids de beneficiarios directos e ids diferentes de 
          # beneficiarios indirectos.  Son únicas si unicos es true
          def calcula_benef_por_sexo(idacs, sexo, ffin, unicos = false)
            contactos =
              Sivel2Sjr::Casosjr.
              joins('JOIN msip_persona ON msip_persona.id=sivel2_sjr_casosjr.contacto_id').
              joins('JOIN sivel2_sjr_actividad_casosjr ON casosjr_id=sivel2_sjr_casosjr.id_caso').
              where(:'msip_persona.sexo' => sexo).
              where(:'sivel2_sjr_actividad_casosjr.actividad_id' => idacs)
            idscontactos = contactos.pluck(:contacto_id)
            if unicos
              idscontactos = idscontactos.uniq
            end
            benef_indir =
              Sivel2Gen::Victima.
              joins('JOIN sivel2_sjr_victimasjr ON sivel2_gen_victima.id=sivel2_sjr_victimasjr.id_victima').
              joins('JOIN msip_persona ON msip_persona.id=sivel2_gen_victima.id_persona').
              joins('JOIN sivel2_sjr_actividad_casosjr ON casosjr_id=sivel2_gen_victima.id_caso').
              where(:'msip_persona.sexo' => sexo).
              where(:'sivel2_sjr_actividad_casosjr.actividad_id' => idacs).
              where('fechadesagregacion IS NULL OR fechadesagregacion > ?', ffin).
              where.not(:'msip_persona.id' => idscontactos)
            idsbenefindir = benef_indir.pluck('id_persona')
            if unicos
              idsbenefindir = idsbenefindir.uniq
            end
            [idscontactos, idsbenefindir]
          end


          # Auxiliar que resume medición de indicadores tipos 30 y 31
          # i.e contar personas en listados de casos en actividades
          def medir_indicador_personas_casos(idacs, mind, fini, ffin, unicos)
            datosint = []
            hombrescasos = calcula_benef_por_sexo(idacs, 'M', ffin, unicos)
            mujerescasos = calcula_benef_por_sexo(idacs, 'F', ffin, unicos)
            sinsexocasos = calcula_benef_por_sexo(idacs, 'S', ffin, unicos)
            contactos = hombrescasos[0] + mujerescasos[0] + sinsexocasos[0]
            familiares = hombrescasos[1] + mujerescasos[1] + sinsexocasos[1]
            resind = contactos.count + familiares.count
            datosint << { valor: contactos.count, rutaevidencia: '#' }
            datosint << { valor: familiares.count, rutaevidencia: '#' }
            if contactos.count > 0
              datosint[0][:rutaevidencia] = msip.personas_path + 
                '?filtro[busid]=' + contactos.join(',')
            end
            if familiares.count > 0
              datosint[1][:rutaevidencia] = msip.personas_path + 
                '?filtro[busid]=' + familiares.join(',')
            end

            return {resind: resind, datosint: datosint}
          end

          # Medición de indicadores contando personas de casos en
          # listados de casos (posiblemente repetidas)
          def medir_indicador_res_tipo_30(idacs, mind, fini, ffin)
            return medir_indicador_personas_casos(
              idacs, mind, fini, ffin, false)
          end

          # Medición de indicadores contando personas únicas de casos en
          # listados de casos 
          def medir_indicador_res_tipo_31(idacs, mind, fini, ffin)
            return medir_indicador_personas_casos(
              idacs, mind, fini, ffin, true)
          end

        end #included

        
        class_methods do

        end

      end
    end
  end
end

