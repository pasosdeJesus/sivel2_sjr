module Sivel2Sjr
  module Concerns
    module Controllers
      module InclusionesController
        extend ActiveSupport::Concern

        included do

          def clase 
            "Sivel2Sjr::Inclusion"
          end

          # Usar retroallmadas para compartir configuracion
          def set_inclusion
            @basica = Sivel2Sjr::Inclusion.find(params[:id])
          end

          def genclase
            return 'F';
          end

          # No confiar en parametros de internet, sino solo los de lista blanca
          def inclusion_params
            params.require(:inclusion).permit(*atributos_form)
          end

        end # included

      end
    end
  end
end

