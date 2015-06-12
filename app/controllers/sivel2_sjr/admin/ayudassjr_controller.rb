# encoding: UTF-8
module Sivel2Sjr
  module Admin
    class AyudassjrController < Sip::Admin::BasicasController
      before_action :set_ayudasjr, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Ayudasjr

      def clase 
        "Sivel2Sjr::Ayudasjr"
      end

      def atributos_index
        ["id",  "nombre" ] + 
          [ :derecho_ids =>  [] ] +
          ["fechacreacion", "fechadeshabilitacion"] 
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_ayudasjr
        @basica = Sivel2Sjr::Ayudasjr.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def ayudasjr_params
        params.require(:ayudasjr).permit(*atributos_form)
      end

    end
  end
end
