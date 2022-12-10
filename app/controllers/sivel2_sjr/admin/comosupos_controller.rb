module Sivel2Sjr
  module Admin
    class ComosuposController <  Msip::Admin::BasicasController
      before_action :set_comosupo, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Comosupo

      def clase 
        "Sivel2Sjr::Comosupo"
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_comosupo
        @basica = Sivel2Sjr::Comosupo.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def comosupo_params
        params.require(:comosupo).permit( *(atributos_index - ["id"]))
      end

      helper_method :clase, :atributos_index
    end
  end
end
