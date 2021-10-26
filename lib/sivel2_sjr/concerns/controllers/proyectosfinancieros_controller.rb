require_dependency 'cor1440_gen/concerns/controllers/proyectosfinancieros_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module ProyectosfinancierosController
        extend ActiveSupport::Concern

        included do

          include Cor1440Gen::Concerns::Controllers::ProyectosfinancierosController

          def atributos_index
            [ 
              :id, 
              :nombre 
            ] +
            [ :financiador_ids =>  [] ] +
            [ 
              :fechainicio_localizada,
              :fechacierre_localizada,
              :responsable
            ] +
            [ :oficina_ids =>  [] ] +
            [ :proyecto_ids =>  [] ] +
            [ 
              :compromisos,
              :monto,
              :observaciones,
              :objetivopf,
              :indicadorobjetivo,
              :resultadopf,
              :indicadorpf,
              :actividadpf
            ] 
          end

        end # included

      end
    end
  end
end

