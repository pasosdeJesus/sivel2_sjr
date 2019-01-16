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

          def inicializa_index
            @plantillas = Heb412Gen::Plantillahcm.
              where(vista: 'Caso').select('nombremenu, id').map { 
              |c| [c.nombremenu, c.id] 
            }
            if current_usuario.rol == ::Ability::ROLINV
              m = current_usuario.etiqueta.map(&:id)
              if m == []
                @conscaso = @conscaso.where(FALSE)
              else
                @conscaso = @conscaso.
                  where("caso_id IN (SELECT id_caso FROM 
                        sivel2_gen_caso_etiqueta WHERE
                        sivel2_gen_caso_etiqueta.id_etiqueta IN 
                          (#{m.join(',')}))")
              end
            end
          end

          # Filtro adicional para autenticar usado por index
          def filtro_particular(conscaso, params_filtro)
            conscaso
          end

          # GET /casos/1
          # GET /casos/1.json
          def show
            # En models/ability.rb agregar
            # can :read, Sivel2Gen::Caso,  etiqueta: { id: usuario.etiqueta.map(&:id) } 
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
                format.html { redirect_to @caso, notice: 'Caso actualizado.' }
                format.json { head :no_content }
                format.js   { redirect_to @caso, notice: 'Caso actualizado.' }
              else
                format.html { render action: 'edit', layout: 'application' }
                format.json { render json: @caso.errors, status: :unprocessable_entity }
                format.js   { render action: 'edit' }
              end
              Sivel2Gen::Conscaso.refresca_conscaso
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

          def otros_params_victima
            []
          end


          def otros_params_respuesta
            []
          end

          def lista_params
            lp = [
              :bienes, 
              :duracion, 
              :fecha, 
              :fecha_localizada, 
              :grconfiabilidad, 
              :gresclarecimiento, 
              :grimpunidad, 
              :grinformacion, 
              :hora, 
              :id, 
              :id_intervalo, 
              :memo, 
              :titulo, 
              :casosjr_attributes => [
                :asesor, 
                :comosupo_id, 
                :contacto, 
                :concentimientosjr, 
                :concentimientobd,
                :categoriaref,
                :dependen, 
                :detcomosupo,
                :direccion, 
                :docrefugiado,
                :estatus_refugio,
                :estrato, 
                :fecharec, 
                :fecharec_localizada, 
                :fechadecrefugio,
                :fechadecrefugio_localizada,
                :fechallegada, 
                :fechallegada_localizada, 
                :fechallegadam, 
                :fechallegadam_localizada, 
                :fechasalida, 
                :fechasalida_localizada, 
                :fechasalidam, 
                :fechasalidam_localizada, 
                :gastos, 
                :ingresomensual, 
                :id, 
                :id_idioma,
                :id_llegada, 
                :id_llegadam, 
                :id_proteccion, 
                :id_salida, 
                :id_salidam, 
                :id_statusmigratorio,
                :leerescribir, 
                :memo1612,
                :motivom,
                :observacionesref,
                :oficina_id, 
                :sustento, 
                :telefono, 
                :_destroy
              ], 
              :victima_attributes => [
                :anotaciones,
                :id, 
                :id_etnia, 
                :id_filiacion, 
                :id_iglesia, 
                :id_organizacion, 
                :id_persona, 
                :id_profesion, 
                :id_rangoedad, 
                :id_vinculoestado, 
                :orientacionsexual, 
                :_destroy 
              ] + otros_params_victima + [
                :persona_attributes => [
                  :apellidos, 
                  :anionac, 
                  :dianac, 
                  :id, 
                  :id_pais, 
                  :id_departamento, 
                  :id_municipio, 
                  :id_clase, 
                  :mesnac, 
                  :nacionalde, 
                  :numerodocumento, 
                  :nombres, 
                  :sexo, 
                  :tdocumento_id
                ],
                :victimasjr_attributes => [
                  :asisteescuela, 
                  :cabezafamilia, 
                  :enfermedad, 
                  :eps, 
                  :fechadesagregacion,
                  :fechadesagregacion_localizada,
                  :id, 
                  :id_victima, 
                  :id_rolfamilia,
                  :id_actividadoficio, 
                  :id_escolaridad,
                  :id_estadocivil, 
                  :id_maternidad, 
                  :id_regimensalud, 
                  :ndiscapacidad, 
                  :sindocumento, 
                  :tienesisben
                ]
              ], 
              :ubicacion_attributes => [
                :id, 
                :id_clase, 
                :id_departamento, 
                :id_municipio, 
                :id_pais, 
                :id_tsitio, 
                :latitud, 
                :longitud, 
                :lugar, 
                :sitio, 
                :_destroy
              ],
              :desplazamiento_attributes => [
                :acompestado, 
                :connacionaldeportado,
                :connacionalretorno,
                :declaro, 
                :descripcion, 
                :documentostierra,
                :fechadeclaracion,
                :fechadeclaracion_localizada,
                :fechaexpulsion, 
                :fechaexpulsion_localizada, 
                :fechallegada, 
                :fechallegada_localizada, 
                :hechosdeclarados,
                :id, 
                :id_acreditacion, 
                :id_clasifdesp, 
                :id_declaroante, 
                :id_expulsion, 
                :id_inclusion,
                :id_llegada, 
                :id_modalidadtierra,
                :id_tipodesp, 
                :inmaterialesperdidos,
                :materialesperdidos, 
                :protegiorupta, 
                :oficioantes, 
                :otrosdatos,
                :retornado,
                :reubicado, 
                :_destroy,
                :categoria_ids => []
              ],
              :caso_presponsable_attributes => [
                :batallon, 
                :bloque, 
                :brigada, 
                :division, 
                :frente, 
                :id, 
                :id_presponsable, 
                :otro, 
                :tipo, 
                :_destroy
              ],
              :acto_attributes => [
                :id, 
                :id_categoria, 
                :id_presponsable, 
                :id_persona, 
                :_destroy,
                :actosjr_attributes => [
                  :desplazamiento_id, 
                  :fecha, 
                  :fecha_localizada, 
                  :id, 
                  :id_acto, 
                  :_destroy
                ]
              ],
              :respuesta_attributes => [
                :accionesder,
                :cantidadayes,
                :compromisos,
                :detalleal, 
                :detalleap, 
                :detalleem, 
                :detallemotivo, 
                :detallear, 
                :descatencion,
                :descamp, 
                :difobsprog,
                :efectividad, 
                :id,
                :id_personadesea, 
                :informacionder, 
                :institucionayes, 
                :fechaatencion, 
                :fechaatencion_localizada, 
                :fechaultima, 
                :fechaultima_localizada, 
                :gestionessjr, 
                :lugar, 
                :lugarultima, 
                :montoal,
                :montoap,
                :montoar,
                :montoem,
                :montoprorrogas,
                :numprorrogas, 
                :observaciones,
                :orientaciones, 
                :remision,  
                :turno,
                :verifcsjr, 
                :verifcper,
                :_destroy, 
                :aslegal_ids => [],
                :aspsicosocial_ids => [],
                :ayudaestado_ids => [],
                :ayudasjr_ids => [],
                :derecho_ids => [],
                :emprendimiento_ids => [],
                :motivosjr_ids => [],
                :progestado_ids => [],
              ] + otros_params_respuesta,
              :anexo_caso_attributes => [
                :fecha_localizada,
                :id, 
                :id_caso,
                :_destroy,
                :sip_anexo_attributes => [
                  :adjunto, 
                  :descripcion, 
                  :id, 
                  :_destroy
                ]
              ],
              :caso_etiqueta_attributes => [
                :fecha, 
                :id, 
                :id_etiqueta, 
                :id_usuario, 
                :observaciones, 
                :_destroy
              ]
           ] 
            lp
          end
 
          # Never trust parameters from the scary internet, only allow the white list through.
          def caso_params
            lp = lista_params + otros_params
            params.require(:caso).permit(lp)
          end

        end

      end
    end
  end
end
