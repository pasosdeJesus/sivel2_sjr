# encoding: UTF-8
module Sivel2Sjr
  module Admin
    class CausasrefController < Sivel2Gen::Admin::BasicasController
      before_action :set_causaref, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Causaref

      def clase 
        "Sivel2Sjr::Causaref"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_causaref
        @basica = Sivel2Sjr::Causaref.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def causaref_params
        params.require(:causaref).permit(*atributos_form)
      end

    end
  end
end
