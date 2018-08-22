# encoding: UTF-8
module Sivel2Sjr
  module Admin
    class AslegalesController < Sip::Admin::BasicasController
      before_action :set_aslegal, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Aslegal

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

    end
  end
end
