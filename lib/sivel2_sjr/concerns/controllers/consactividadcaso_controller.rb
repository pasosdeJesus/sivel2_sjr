# encoding: UTF-8

module Sivel2Sjr
  module Concerns
    module Controllers
      module ConsactividadcasoController
        extend ActiveSupport::Concern


        included do

          def clase
            'Sivel2Sjr::Consactividadcaso'
          end

          def atributos_index
            [:caso_id,
             :actividad_id,
             :actividad_fecha,
             :actividad_proyectofinanciero,
             :persona_nombres,
             :persona_apellidos,
             :tipos_actividad
            ]
          end
          
          def index_reordenar(c)
            aapf = Cor1440Gen::ActividadActividadpf.where(actividad_id: 
                                                         c.pluck(:actividad_id))
            apf= Cor1440Gen::Actividadpf.where(id: aapf.pluck(:actividadpf_id))
      

            @actipos = Cor1440Gen::Actividadtipo.where(
              id: apf.pluck(:actividadtipo_id)).pluck(:id, :nombre)
            c.reorder([:caso_id, :actividad_id])
          end 
            
          def index_plantillas
          end 

          # Genera conteo por caso/beneficiario y tipo de actividad de convenio
          # #caso #act fechaact nom ap id gen edadfact rangoedad_fact etnia tipoac1 tipoac2 tipoac3 tipoac4 ... oficina asesoract 
          #                 EDADES HOMBRES            EDADES MUJERES                    
          #                                 0-5 6-12  13-17 18-26 27-59 +60 0-5 6-12  13-17 18-26 27-59 +60         
          def index
            Sivel2Sjr::Consactividadcaso.crea_consulta

            index_sip(Sivel2Sjr::Consactividadcaso.all)
          end

        end #included

      end
    end
  end
end

