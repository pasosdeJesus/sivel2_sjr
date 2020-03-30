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

            @registro.proyectofinanciero_ids += 
              [Cor1440Gen::ActividadesController.pf_planest_id]
            Cor1440Gen::ActividadesController.posibles_nuevaresp.
              each do |s, lnumacpf|
              if params[s] && params[s] == "true"
                tipo = Cor1440Gen::Actividadpf.
                  find(lnumacpf[1]).actividadtipo_id
                presente_otros = Cor1440Gen::Actividadpf.
                  where(actividadtipo_id: tipo).pluck(:id)
                @registro.actividadpf_ids |= 
                  [Cor1440Gen::ActividadesController.actividadpf_segcas_id,
                   lnumacpf[1]]
                @registro.actividadpf_ids |= presente_otros
              end

            end
            @registro.save!(validate: false)
          end

          def new
            new_ac_sivel2_sjr

            redirect_to cor1440_gen.edit_actividad_path(@registro)
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

        
        class_methods do

          def posibles_nuevaresp
            return {
              ahumanitaria: ['Asistencia humanitaria', 11],
              apsicosocial: ['Asistencia psicosocial', 13],
              alegal: ['Asistencia legal', 14],
            } 
          end

          # Retorna datos por enviar a nuevo de este controlador
          # desde javascript cuando se añade una respuesta a un caso
          def datos_nuevaresp(caso, controller)
            return {
              nombre: "Seguimiento/Respuesta a caso #{caso.id}",
              oficina_id: caso.casosjr.oficina_id,
              caso_id: caso.id, 
              #proyecto_id: 101,
              usuario_id: controller.current_usuario.id 
            } 
          end

          def pf_planest_id
            10
          end

          def actividadpf_segcas_id
            10
          end

        end

      end
    end
  end
end

