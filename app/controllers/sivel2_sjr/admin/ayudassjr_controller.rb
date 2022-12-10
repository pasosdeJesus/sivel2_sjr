module Sivel2Sjr
  module Admin
    class AyudassjrController < Msip::Admin::BasicasController
      before_action :set_ayudasjr, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Ayudasjr

      def clase 
        "Sivel2Sjr::Ayudasjr"
      end

      def atributos_index
        ["id",  "nombre" ] + 
          [ :derecho_ids =>  [] ] +
          ["observaciones", "fechacreacion", "habilitado"] 
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_ayudasjr
        @basica = Sivel2Sjr::Ayudasjr.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def ayudasjr_params
        params.require(:ayudasjr).permit(*atributos_form)
      end

      # Elimina un registro 
      def destroy
        # No se ha logrado con before_destroy en modelo
        mens = ""
        if @basica.derecho
          porb = Sivel2Sjr::AyudasjrDerecho.where(ayudasjr_id: @basica.id)
          cuenta = porb.count
          if cuenta > 0
            porb.delete_all
            mens += " Se han eliminado automáticamente #{cuenta} registros " +
              " relacionados de la tabla " + 
              Sivel2Sjr::AyudasjrDerecho.human_attribute_name(
                :ayudasjr_derecho) + ". "
          end
        end
        super(mens)
#        @basica.destroy
#        respond_to do |format|
#          format.html { redirect_to admin_basicas_url(@basica) }
#          format.json { head :no_content }
#        end
      end

    end
  end
end
