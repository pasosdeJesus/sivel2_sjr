module Sivel2Sjr
  module Admin
    class IdiomasController < Msip::Admin::BasicasController
      before_action :set_idioma, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Idioma

      def clase 
        "Sivel2Sjr::Idioma"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_idioma
        @basica = Sivel2Sjr::Idioma.find(params[:id])
      end

      def genclase
        return 'M';
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def idioma_params
        params.require(:idioma).permit(*atributos_form)
      end

    end
  end
end
