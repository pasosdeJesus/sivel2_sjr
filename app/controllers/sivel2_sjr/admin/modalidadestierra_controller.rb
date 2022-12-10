module Sivel2Sjr
  module Admin
    class ModalidadestierraController < Msip::Admin::BasicasController
      before_action :set_modalidadtierra, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Modalidadtierra

      def clase 
        "Sivel2Sjr::Modalidadtierra"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_modalidadtierra
        @basica = Sivel2Sjr::Modalidadtierra.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def modalidadtierra_params
        params.require(:modalidadtierra).permit(*atributos_form)
      end

    end
  end
end
