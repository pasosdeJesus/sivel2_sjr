module Sivel2Sjr
  module Admin
    class PersonadeseasController < Msip::Admin::BasicasController
      before_action :set_personadesea, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Personadesea

      def clase 
        "Sivel2Sjr::Personadesea"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_personadesea
        @basica = Sivel2Sjr::Personadesea.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def personadesea_params
        params.require(:personadesea).permit(*atributos_form)
      end

    end
  end
end
