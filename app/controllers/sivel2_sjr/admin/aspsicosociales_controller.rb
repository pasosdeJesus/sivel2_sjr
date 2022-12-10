module Sivel2Sjr
  module Admin
    class AspsicosocialesController < Msip::Admin::BasicasController
      before_action :set_aspsicosocial, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Aspsicosocial

      def clase 
        "Sivel2Sjr::Aspsicosocial"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_aspsicosocial
        @basica = Sivel2Sjr::Aspsicosocial.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def aspsicosocial_params
        params.require(:aspsicosocial).permit(*atributos_form)
      end

    end
  end
end
