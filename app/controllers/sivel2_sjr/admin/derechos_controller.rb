module Sivel2Sjr
  module Admin
    class DerechosController < Msip::Admin::BasicasController
      before_action :set_derecho, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Derecho

      def clase 
        "Sivel2Sjr::Derecho"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_derecho
        @basica = Sivel2Sjr::Derecho.find(params[:id])
      end

      def genclase
        return 'M';
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def derecho_params
        params.require(:derecho).permit(*atributos_form)
      end

    end
  end
end
