# encoding: UTF-8

require_dependency 'sivel2_gen/concerns/controllers/casos_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module CasosController
        extend ActiveSupport::Concern

        include Sivel2Gen::Concerns::Controllers::CasosController

        included do
          # Tuve que repetir las siguientes que tambien estan en 
          # Sivel2Gen::Concerns::Controllers::CasosController 
          # pero que no son llamadas 
          before_action :set_caso, only: [:show, :edit, :update, :destroy]
          load_and_authorize_resource class: Sivel2Gen::Caso
          helper Sip::UbicacionHelper

          # Campos en filtro
          def campos_filtro1
            [:codigo,
              :fechaini, :fechafin, 
              :fecharecini, :fecharecfin, 
              :oficina_id, :usuario_id,
              :ultimaatencion_fechaini, :ultimaatencion_fechafin,
              :statusmigratorio_id,
              :nombressp, :apellidossp,
              :nombres, :apellidos, :sexo, :rangoedad_id, 
              :categoria_id,
              :descripcion
            ]
          end

          # Campos por presentar en listado index
          def incluir_inicial
            ['casoid', 'contacto', 'fecharec', 'oficina', 
              'nusuario', 'fecha', 'statusmigratorio',
              'ultimaatencion_fecha', 'memo'
            ]
          end


          # Ordenamiento inicial por este campo
          def campoord_inicial
            'fecharec'
          end

          def cortamemo
            200
          end

          # Filtro adicional para autenticar usado por index
          def filtro_particular(conscaso, params_filtro)
            if (current_usuario.rol == Ability::ROLINV) 
              return conscaso.where(
                "caso_id IN (SELECT id_caso FROM 
                    sivel2_gen_caso_etiqueta AS caso_etiqueta, 
                    sivel2_sjr_etiqueta_usuario AS etiqueta_usuario 
                    WHERE caso_etiqueta.id_etiqueta=etiqueta_usuario.etiqueta_id
                    AND etiqueta_usuario.usuario_id ='" + 
                current_usuario.id.to_s + "')")
            else
              return conscaso
            end
          end

          # GET /casos/1
          # GET /casos/1.json
          def show
            # No hemos logrado poner con cancan la condición para ROLINV en 
            # models/ability.rb
            if current_usuario.rol == Ability::ROLINV
              ace = @caso.caso_etiqueta.map { |ce| ce.id_etiqueta }
              aeu = current_usuario.etiqueta_usuario.map { |eu| eu.etiqueta_id }
              ie = ace & aeu
              if (ie.size == 0)
                raise CanCan::AccessDenied.new("Invitado no autorizado!", :read, Caso)
              end
            end
            render layout: 'application'
          end

          # GET /casos/new
          def new
            @caso.current_usuario = current_usuario
            @caso.fecha = DateTime.now.strftime('%Y-%m-%d')
            @caso.memo = ''
            @caso.casosjr = Sivel2Sjr::Casosjr.new
            @caso.casosjr.fecharec = DateTime.now.strftime('%Y-%m-%d')
            @caso.casosjr.asesor = current_usuario.id
            @caso.casosjr.oficina_id= current_usuario.oficina_id.nil? ?  
              1 : current_usuario.oficina_id
            per = Sip::Persona.new
            per.nombres = ''
            per.apellidos = ''
            per.sexo = 'S'
            per.save!(validate: false)
            vic = Sivel2Gen::Victima.new
            vic.persona = per
            @caso.victima<<vic
            @caso.casosjr.contacto = per
            @caso.save!(validate: false)
            vic.id_caso = @caso.id
            vic.save!(validate: false)
            logger.debug "Victima salvada: #{vic.inspect}"
            #debugger
            vic.victimasjr = Sivel2Sjr::Victimasjr.new
            vic.victimasjr.id_victima = vic.id
            vic.victimasjr.save!(validate: false)
            cu = Sivel2Gen::CasoUsuario.new
            cu.id_usuario = current_usuario.id
            cu.id_caso = @caso.id
            cu.fechainicio = DateTime.now.strftime('%Y-%m-%d')
            cu.save!(validate: false)
            if session[:capturacaso_acordeon] 
              render 'newv', layout: 'application'
            else
              render 'new', layout: 'application'
            end
          end

          # PATCH/PUT /casos/1
          # PATCH/PUT /casos/1.json
          def update
            # No deben venir validaciones en controlador
            respond_to do |format|
              if (!params[:caso][:caso_etiqueta_attributes].nil?)
                params[:caso][:caso_etiqueta_attributes].each {|k,v|
                  if (v[:id_usuario].nil? || v[:id_usuario] == "") 
                    v[:id_usuario] = current_usuario.id
                  end
                }
              end
              if (!params[:caso][:respuesta_attributes].nil?)
                params[:caso][:respuesta_attributes].each {|k,v|
                  if (v[:id_caso].nil?) 
                    v[:id_caso] = @caso.id
                  end
                }
              end
              @caso.current_usuario = current_usuario
              if @caso.update(caso_params)
                Sivel2Gen::Conscaso.refresca_conscaso
                format.html { redirect_to @caso, notice: 'Caso actualizado.' }
                format.json { head :no_content }
                format.js   { redirect_to @caso, notice: 'Caso actualizado.' }
              else
                format.html { render action: 'edit', layout: 'application' }
                format.json { render json: @caso.errors, status: :unprocessable_entity }
                format.js   { render action: 'edit' }
              end
            end
          end

          # DELETE /casos/1.json
          # Este método obligó a definir sivel2_gen_destroy en sivel2_gen/concerns/controllers/casos_controllers
          # y a repetir before_action :set_caso, only: [:show, :edit, :update, :destroy]
          # en el included do de este
          def sivel2_sjr_destroy
            if @caso.casosjr.respuesta
              # No se logró hacer ni con dependente:destroy en
              # las relaciones ni borrando con delete 
              @caso.casosjr.respuesta.each do |r|
                Sivel2Sjr::AslegalRespuesta.where(id_respuesta: r.id).delete_all
                #r.aslegal_respuesta.delete
                Sivel2Sjr::AyudaestadoRespuesta.where(id_respuesta: r.id).delete_all
                #r.ayudaestado_respuesta.delete
                Sivel2Sjr::AyudasjrRespuesta.where(id_respuesta: r.id).delete_all
                #r.ayudasjr_respuesta.delete
                Sivel2Sjr::DerechoRespuesta.where(id_respuesta: r.id).delete_all
                #r.derecho_respuesta.delete
                Sivel2Sjr::MotivosjrRespuesta.where(id_respuesta: r.id).delete_all
                #r.motivosjr_respuesta.delete
                Sivel2Sjr::ProgestadoRespuesta.where(id_respuesta: r.id).delete_all
                #r.progestado_respuesta.delete
              end
              @caso.casosjr.respuesta.delete
              Sivel2Sjr::Respuesta.where(id_caso: @caso.id).delete_all
            end
            @caso.casosjr.destroy if @caso.casosjr
            sivel2_gen_destroy
            Sivel2Gen::Conscaso.refresca_conscaso
          end

          def destroy
            sivel2_sjr_destroy
          end

          private

          def otros_params
            []
          end

          # Never trust parameters from the scary internet, only allow the white list through.
          def caso_params
            params.require(:caso).permit([
              :id, :titulo, :fecha, :hora, :duracion, 
              :grconfiabilidad, :gresclarecimiento, :grimpunidad, :grinformacion, 
              :bienes, :id_intervalo, :memo, 
              :casosjr_attributes => [
                :id, :fecharec, :asesor, :oficina_id, :direccion, 
                :telefono, :comosupo_id, :contacto, :detcomosupo,
                :dependen, :sustento, :leerescribir, 
                :ingresomensual, :gastos, :estrato, :id_statusmigratorio,
                :id_proteccion, :id_idioma,
                :concentimientosjr, :concentimientobd,
                :fechasalida, :id_salida, 
                :fechallegada, :id_llegada, 
                :categoriaref,
                :observacionesref,
                :memo1612,
                :_destroy
            ], 
              :victima_attributes => [
                :id, :id_persona, :id_profesion, :id_rangoedad, :id_etnia, 
                :id_filiacion, :id_organizacion, :id_vinculoestado, :anotaciones,
                :id_iglesia, :orientacionsexual, 
                :_destroy, 
                :persona_attributes => [
                  :id, :nombres, :apellidos, :anionac, :mesnac, :dianac, 
                  :id_pais, :id_departamento, :id_municipio, :id_clase, 
                  :nacionalde, :numerodocumento, :sexo, :tdocumento_id
            ],
              :victimasjr_attributes => [
                :id, :id_victima, :id_rolfamilia,
                :id_actividadoficio, :id_estadocivil, 
                :id_maternidad, :ndiscapacidad, :enfermedad, 
                :id_escolaridad,
                :sindocumento, :cabezafamilia, :asisteescuela, 
                :fechadesagregacion,
                :id_regimensalud, :eps, :tienesisben
            ]
            ], 
              :ubicacion_attributes => [
                :id, :id_pais, :id_departamento, :id_municipio, :id_clase, 
                :lugar, :sitio, :latitud, :longitud, :id_tsitio, 
                :_destroy
            ],
              :desplazamiento_attributes => [
                :id, :fechaexpulsion, :id_expulsion, 
                :fechallegada, :id_llegada, :descripcion, 
                :id_clasifdesp, :id_tipodesp, :otrosdatos,
                :declaro, :hechosdeclarados, :fechadeclaracion,
                :id_declaroante, :id_inclusion,
                :id_acreditacion, :retornado,
                :reubicado, :connacionalretorno,
                :acompestado, :connacionaldeportado,
                :oficioantes, :id_modalidadtierra,
                :materialesperdidos, :inmaterialesperdidos,
                :protegiorupta, :documentostierra,
                :_destroy,
                :categoria_ids => []
            ],
              :caso_presponsable_attributes => [
                :id, :id_presponsable, :tipo, 
                :bloque, :frente, :brigada, :batallon, :division, :otro, 
                :_destroy
            ],
              :acto_attributes => [
                :id, :id_presponsable, :id_categoria, :id_persona, :_destroy,
                :actosjr_attributes => [
                  :id, :id_acto, :fecha, :desplazamiento_id, :_destroy
            ]
            ],
              :respuesta_attributes => [
                :id,
                :fechaatencion, 
                :numprorrogas, :montoprorrogas,
                :fechaultima, :lugarultima, :turno,
                :lugar, :descamp, :compromisos,
                :remision,  :orientaciones, 
                :gestionessjr, :observaciones,
                :id_personadesea, :verifcsjr, :verifcper,
                :efectividad, 
                :detalleal, :montoal,
                :detalleap, :montoap,
                :institucionayes, :cantidadayes,
                :detallear, :montoar,
                :informacionder, :accionesder,
                :detalleem, :montoem,
                :detallemotivo, 
                :descatencion,
                :difobsprog,
                :_destroy, 
                :aslegal_ids => [],
                :aspsicosocial_ids => [],
                :ayudaestado_ids => [],
                :ayudasjr_ids => [],
                :derecho_ids => [],
                :emprendimiento_ids => [],
                :motivosjr_ids => [],
                :progestado_ids => [],
            ],
            :anexo_caso_attributes => [
              :id, 
              :id_caso,
              :fecha,
              :_destroy,
              :sip_anexo_attributes => [
                :id, :descripcion, :adjunto, :_destroy
            ]
            ],
              :caso_etiqueta_attributes => [
                :id, :id_usuario, :fecha, :id_etiqueta, :observaciones, :_destroy
            ]
            ] + otros_params
            )
          end

        end

      end
    end
  end
end
