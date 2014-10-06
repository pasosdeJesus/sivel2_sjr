# encoding: UTF-8
module Admin
  class DerechosController < BasicasController
    before_action :set_derecho, only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource

    def clase 
      "derecho"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_derecho
      @basica = Derecho.find(params[:id])
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
