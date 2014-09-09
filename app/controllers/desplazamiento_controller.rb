require 'date'

class DesplazamientoController < ApplicationController
  load_and_authorize_resource

  # Crea un nuevo desplazamiento para el caso que recibe por parametro params[:caso_id]
  # Pone valores simples en los campos requeridos
  def nuevo
    if params[:caso_id].nil?
      respond_to do |format|
        format.html { render inline: 'Falta identificacion del caso' }
      end
    elsif Ubicacion.where(id_caso: params[:caso_id].to_i).count < 2
      respond_to do |format|
        format.html { render inline: 'Debe tener al menos 2 ubicaciones' }
      end
    else
      @desplazamiento = Desplazamiento.new
      cid = params[:caso_id].to_i
      @desplazamiento.id_caso = cid
      fex = Caso.find(cid).fecha
      while (Desplazamiento.where(id_caso: cid, fechaexpulsion: fex.to_s).count > 0) do
        fex += 1
      end
      @desplazamiento.fechaexpulsion = fex
      @desplazamiento.id_expulsion = Ubicacion.where(id_caso: cid).last.id
      @desplazamiento.fechallegada = fex+1
      @desplazamiento.id_llegada = Ubicacion.where(id_caso: cid).first.id
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
          format.html { render action: "error" }
          format.json { 
            render json: @desplazamiento.errors, 
            status: :unprocessable_entity
          }
        end
      end
    end
  end
end
