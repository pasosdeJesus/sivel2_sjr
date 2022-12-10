module Sivel2Sjr
  module Admin
    class TiposdespController < Msip::Admin::BasicasController
      before_action :set_tipodesp, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Tipodesp

      def clase 
        "Sivel2Sjr::Tipodesp"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_tipodesp
        @basica = Sivel2Sjr::Tipodesp.find(params[:id])
      end

      def genclase
        return 'M';
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def tipodesp_params
        params.require(:tipodesp).permit(*atributos_form)
      end

    end
  end
end
