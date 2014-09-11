require 'date'

class RespuestasController < ApplicationController
  load_and_authorize_resource

  # Crea un nuevo registro para el caso que recibe por parametro 
  # params[:caso_id].  Pone valores simples en los campos requeridos
  def nuevo
    if params[:caso_id].nil?
      respond_to do |format|
        format.html { render inline: 'Falta identificacion del caso' }
      end
    else
      @respuesta = Respuesta.new
      cid = params[:caso_id].to_i
      @respuesta.id_caso = cid
      @respuesta.detallear = ''
      @respuesta.detalleal = ''
      @respuesta.detalleap = ''
      @respuesta.detalleem = ''
      @respuesta.institucionayes = ''
      @respuesta.accionesder = ''
      @respuesta.detallemotivo = ''
      @respuesta.difobsprog = ''
      fex = Date.today
      while (Respuesta.where(fechaatencion: fex.to_s).count > 0) do
        fex += 1
      end
      @respuesta.fechaatencion = fex
      if @respuesta.save
        h=@respuesta.as_json
        h['respuesta'] = @respuesta.id
        respond_to do |format|
          format.js { render text: h }
          format.json { render json: h, status: :created }
          format.html { render inline: h.to_s }
        end
      else
        respond_to do |format|
          format.html { render action: "error" }
          format.json { 
            render json: @respuesta.errors, 
            status: :unprocessable_entity
          }
        end
      end
    end
  end
end
