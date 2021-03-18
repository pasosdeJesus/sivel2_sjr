# encoding: UTF-8
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
      elsif Sip::Ubicacion.where(id_caso: params[:caso_id].to_i).count < 2
        respond_to do |format|
          format.html { render inline: 'Debe tener al menos 2 ubicaciones' }
        end
      else
        @desplazamiento = Sivel2Sjr::Desplazamiento.new
        cid = params[:caso_id].to_i
        @desplazamiento.id_caso = cid
        fex = Sivel2Gen::Caso.find(cid).fecha
        while (Sivel2Sjr::Desplazamiento.where(id_caso: cid, 
            fechaexpulsion: fex.to_s).count > 0) do
          fex += 1
        end
        @desplazamiento.fechaexpulsion = fex
        @desplazamiento.fechallegada = fex+1
        ubiex = Sip::Ubicacion.where(id_caso: cid).last
        ubicacionpre = Sip::Ubicacionpre.where(
          pais_id: ubiex.id_pais, departamento_id: ubiex.id_departamento, 
          municipio_id: ubiex.id_municipio, clase_id: ubiex.id_clase)
        @desplazamiento.expulsionubicacionpre_id = ubicacionpre[0].id
        ubilleg = Sip::Ubicacion.where(
          id_caso: cid).first
        ubicacionpre = Sip::Ubicacionpre.where(
          pais_id: ubilleg.id_pais, departamento_id: ubilleg.id_departamento, 
          municipio_id: ubilleg.id_municipio, clase_id: ubilleg.id_clase)
        @desplazamiento.llegadaubicacionpre_id = ubicacionpre[0].id 
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
end
