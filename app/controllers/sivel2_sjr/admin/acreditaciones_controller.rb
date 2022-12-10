module Sivel2Sjr
  module Admin
    class AcreditacionesController < Msip::Admin::BasicasController
      before_action :set_acreditacion, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Acreditacion

      def clase 
        "Sivel2Sjr::Acreditacion"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_acreditacion
        @basica = Sivel2Sjr::Acreditacion.find(params[:id])
      end

      def genclase
        return 'M';
      end


      # Never trust parameters from the scary internet, only allow the white list through.
      def acreditacion_params
        params.require(:acreditacion).permit(*atributos_form)
      end

    end
  end
end
