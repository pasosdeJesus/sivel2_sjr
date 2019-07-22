# encoding: UTF-8

require_dependency 'cor1440_gen/concerns/controllers/actividades_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module ActividadesController
        extend ActiveSupport::Concern


        included do
          include Cor1440Gen::Concerns::Controllers::ActividadesController

          Cor1440Gen.actividadg1 = "Mujeres empleadas SJR"
          Cor1440Gen.actividadg3 = "Hombres empleados SJR"


          def atributos_show
            [ :id, 
              :nombre, 
              :fecha_localizada, 
              :lugar, 
              :oficina, 
              :proyectofinanciero, 
              :proyectos,
              :actividadareas, 
              :responsable,
              :corresponsables,
              :actividadpf, 
              :respuestafor,
              :objetivo,
              :resultado, 
              :listadocasosjr,
              :actorsocial,
              :listadoasistencia,
              :poblacion,
              :anexos
            ]
          end

          def lista_params_sivel2_sjr
            lista_params_cor1440_gen  + [
              :actividad_casosjr_attributes => [
                :casosjr_id,
                :id,
                :_destroy ]
            ]
          end

          def lista_param
            lista_params_sivel2_sjr
          end

        end #included

      end
    end
  end
end

