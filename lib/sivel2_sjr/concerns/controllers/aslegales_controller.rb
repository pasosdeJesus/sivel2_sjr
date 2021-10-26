module Sivel2Sjr
  module Concerns
    module Controllers
      module AslegalesController
        extend ActiveSupport::Concern

        included do

          def clase 
            "Sivel2Sjr::Aslegal"
          end

          # Use callbacks to share common setup or constraints between actions.
          def set_aslegal
            @basica = Sivel2Sjr::Aslegal.find(params[:id])
          end

          def genclase
            return 'F';
          end


          # Never trust parameters from the scary internet, only allow the white list through.
          def aslegal_params
            params.require(:aslegal).permit(*atributos_form)
          end

        end # included

      end
    end
  end
end
