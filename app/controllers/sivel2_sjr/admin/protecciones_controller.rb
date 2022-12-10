module Sivel2Sjr
  module Admin
    class ProteccionesController < Msip::Admin::BasicasController
      before_action :set_proteccion, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Proteccion

      def clase 
        "Sivel2Sjr::Proteccion"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_proteccion
        @basica = Sivel2Sjr::Proteccion.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def proteccion_params
        params.require(:proteccion).permit(*atributos_form)
      end

    end
  end
end
