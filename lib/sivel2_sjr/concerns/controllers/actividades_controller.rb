# encoding: UTF-8

require_dependency 'cor1440_gen/concerns/controllers/actividades_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module ActividadesController
        extend ActiveSupport::Concern


        included do
          include Cor1440Gen::Concerns::Controllers::ActividadesController

          Cor1440Gen.actividadg1 = "Mujeres empleadas SJR"
          Cor1440Gen.actividadg3 = "Hombres empleados SJR"


          def atributos_show
            [ :id, 
              :nombre, 
              :fecha_localizada, 
              :lugar, 
              :oficina, 
              :proyectofinanciero, 
              :proyectos,
              :actividadareas, 
              :responsable,
              :corresponsables,
              :actividadpf, 
              :respuestafor,
              :objetivo,
              :resultado, 
              :listadocasosjr,
              :actorsocial,
              :listadoasistencia,
              :poblacion,
              :anexos
            ]
          end

          def new_ac_sivel2_sjr
            new_cor1440_gen
            @registro.fecha = Date.today
            if params['usuario_id'] && 
                ::Usuario.where(id: params['usuario_id'].to_i).count == 1
              @registro.usuario_id = params['usuario_id'].to_i
            end
            if params['oficina_id'] && 
                Sip::Oficina.where(id: params['oficina_id'].to_i).count == 1
              @registro.oficina_id = params['oficina_id'].to_i
            end
            if params['proyecto_id'] && 
                Cor1440Gen::Proyecto.where(id: params['proyecto_id'].to_i).count == 1
              @registro.proyecto_ids = [params['proyecto_id'].to_i]
            end
            if params['nsegresp_proyectofinanciero_id'] && 
                Cor1440Gen::Proyectofinanciero.where(
                  id: params['nsegresp_proyectofinanciero_id'].to_i).count == 1
            @registro.proyectofinanciero_ids |= [params[
              'nsegresp_proyectofinanciero_id'].to_i]
            end
            if params['nombre'] 
              @registro.nombre = params['nombre']
            end
            @registro.actividadpf_ids = []
            @registro.save!(validate: false)

            if params['caso_id'] && 
                Sivel2Sjr::Casosjr.where(id_caso: params['caso_id'].to_i).
                count == 1
              @registro.casosjr_ids = [params['caso_id']]
              @registro.save!(validate: false)
              Sivel2Sjr::PoblacionHelper.crea_poblacion_rangoedadac(
                @registro.id, @registro.casosjr_ids[0], @registro.fecha.year, 
                @registro.fecha.month, @registro.fecha.day)
            end
          end

          def new_particular
            @registro.proyectofinanciero_ids += [10]

            if params[:ahumanitaria] == "true"
              @registro.actividadpf_ids |=  [10, 11] # SEGCAS, ASHUM
            end
            if params[:emprendimiento] == "true"
              @registro.actividadpf_ids |=  [10, 12] # SEGCAS, EMP
            end
            if params[:apsicosocial] == "true"
              @registro.actividadpf_ids |=  [10, 13] # SEGCAS, ASPSI
            end
            if params[:alegal] == "true"
              @registro.actividadpf_ids |=  [10, 14] # SEGCAS, ASLEG
            end
            @registro.save!(validate: false)
          end

          def new
            new_ac_sivel2_sjr
            new_particular

            redirect_to cor1440_gen.edit_actividad_path(@registro)
          end


          # API, retorna población por sexo y rango de edad (sin modificar
          # base de datos)
          def poblacion_sexo_rangoedadac
            caso_id = params[:id_caso].to_i
            fecha = Sip::FormatoFechaHelper.fecha_local_estandar(
              params[:fecha])
            if !fecha
              render json: "No se pudo convertir fecha #{params[:fecha]}",
                status: :unprocessable_entity 
              return
            end
            fecha = Date.strptime(fecha, '%Y-%m-%d')

            anio = fecha.year
            mes = fecha.month
            dia = fecha.day
            casosjr = Sivel2Sjr::Casosjr.where(id_caso: caso_id)
            if casosjr.count == 0
              render json: "No se encontró caso #{caso_id}",
                status: :unprocessable_entity 
              return
            end
            rangoedad = {'S' => {}, 'M' => {}, 'F' => {}}
            totsexo = {}
            Sivel2Gen::RangoedadHelper.poblacion_por_sexo_rango(
              casosjr.take.id_caso, fecha.year, fecha.month, fecha.day,
              'Cor1440Gen::Rangoedadac', rangoedad, totsexo)
            render json: rangoedad, status: :ok
          end


          def lista_params_sivel2_sjr
            lista_params_cor1440_gen  + [
              :actividad_casosjr_attributes => [
                :casosjr_id,
                :id,
                :_destroy ]
            ]
          end

          def lista_params
            lista_params_sivel2_sjr
          end

        end #included

      end
    end
  end
end

