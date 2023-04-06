require 'date'

module Sivel2Sjr
  class DesplazamientosController < ApplicationController
    load_and_authorize_resource class: Sivel2Sjr::Desplazamiento

    # Crea un nuevo desplazamiento para el caso que recibe por parametro params[:caso_id]
    # Pone valores simples en los campos requeridos
    def nuevo
      if params[:caso_id].nil?
        respond_to do |format|
          format.html { render inline: 'Falta identificacion del caso' }
        end
#      elsif Msip::Ubicacion.where(caso_id: params[:caso_id].to_i).count < 2
#        respond_to do |format|
#          format.html { render inline: 'Debe tener al menos 2 ubicaciones' }
#        end
      else
        @desplazamiento = Sivel2Sjr::Desplazamiento.new
        cid = params[:caso_id].to_i
        @desplazamiento.caso_id = cid
        fex = Sivel2Gen::Caso.find(cid).fecha
        while (Sivel2Sjr::Desplazamiento.where(caso_id: cid, 
            fechaexpulsion: fex.to_s).count > 0) do
          fex += 1
        end
        @desplazamiento.fechaexpulsion = fex
        #@desplazamiento.expulsion_id = Msip::Ubicacion.where(caso_id: cid).last.id
        @desplazamiento.fechallegada = fex+1
        #@desplazamiento.llegada_id = Msip::Ubicacion.where(
          #caso_id: cid).first.id
        @desplazamiento.descripcion = ''
        if @desplazamiento.save
          h=@desplazamiento.as_json
          h['desplazamiento'] = @desplazamiento.id
          respond_to do |format|
            format.js { render text: h }
            format.json { render json: h, status: :created }
            format.html { render inline: h.to_s }
          end
        else
          respond_to do |format|
            format.html { render inline: "errores: #{@desplazamiento.errors.messages}" }
            format.json { 
              render json: @desplazamiento.errors.messages, 
              status: :unprocessable_entity
            }
          end
        end
      end
    end
  end
end
