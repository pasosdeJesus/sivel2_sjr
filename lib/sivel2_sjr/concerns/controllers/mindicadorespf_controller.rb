# encoding: UTF-8

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
              joins('JOIN sip_persona ON sip_persona.id=sivel2_sjr_casosjr.contacto_id').
              joins('JOIN sivel2_sjr_actividad_casosjr ON casosjr_id=sivel2_sjr_casosjr.id_caso').
              where(:'sip_persona.sexo' => sexo).
              where(:'sivel2_sjr_actividad_casosjr.actividad_id' => idacs)
            idscontactos = contactos.pluck(:contacto_id)
            if unicos
              idscontactos = idscontactos.uniq
            end
            benef_indir =
              Sivel2Gen::Victima.
              joins('JOIN sivel2_sjr_victimasjr ON sivel2_gen_victima.id=sivel2_sjr_victimasjr.id_victima').
              joins('JOIN sip_persona ON sip_persona.id=sivel2_gen_victima.id_persona').
              joins('JOIN sivel2_sjr_actividad_casosjr ON casosjr_id=sivel2_gen_victima.id_caso').
              where(:'sip_persona.sexo' => sexo).
              where(:'sivel2_sjr_actividad_casosjr.actividad_id' => idacs).
              where('fechadesagregacion IS NULL OR fechadesagregacion > ?', ffin).
              where.not(:'sip_persona.id' => idscontactos)
            idsbenefindir = benef_indir.pluck('id_persona')
            if unicos
              idsbenefindir = idsbenefindir.uniq
            end
            [idscontactos, idsbenefindir]
          end

          
          def mideindicador_sivel2_sjr(mind, ind, fini, ffin)
            resind = 0.0
            idacs = []
            urlevrind = ''
            d1 = 0.0
            urlev1 = ''
            d2 = 0.0
            urlev2 = ''
            d3 = 0.0
            urlev3 = ''

            if ind.tipoindicador_id == 30 || ind.tipoindicador_id == 31
              unicos = false
              # Cuentas intermedias: (1) contactos + (2) beneficiarios 
              if ind.tipoindicador_id == 31
                # Cuentas intermedias: (1) contactos + (2) beneficiarios 
                # unicos
                unicos = true
              end
              idacs = calcula_listado_ac(mind.actividadpf_ids, fini, ffin)
              hombrescasos = calcula_benef_por_sexo(idacs, 'M', ffin, unicos)
              mujerescasos = calcula_benef_por_sexo(idacs, 'F', ffin, unicos)
              sinsexocasos = calcula_benef_por_sexo(idacs, 'S', ffin, unicos)
              benef_dir = hombrescasos[0] + mujerescasos[0] + sinsexocasos[0]
              benef_indir = hombrescasos[1] + mujerescasos[1] + sinsexocasos[1]
              resind = benef_dir.count + benef_indir.count
              if idacs.count > 0
                urlevrind = cor1440_gen.actividades_url +
                  '?filtro[busid]=' + idacs.join(',')
              end
              if benef_dir.count > 0
                urlevdir = sip.personas_path + '?filtro[busid]=' + 
                  benef_dir.join(',')
              end
              if benef_indir.count > 0
                urlevindir = sip.personas_path + '?filtro[busid]=' + 
                  benef_indir.join(',')
              end

              return [ resind, urlevrind, 
                       benef_dir, urlevdir, 
                       benef_indir, urlevindir, 
                       -1, '#' ]
            end
            return mideindicador_cor1440_gen(mind, ind, fini, ffin)
          end


          def mideindicador_particular(mind, ind, fini, ffin)
            mideindicador_sivel2_sjr(mind, ind, fini, ffin)  
          end

        end #included

        
        class_methods do

        end

      end
    end
  end
end

