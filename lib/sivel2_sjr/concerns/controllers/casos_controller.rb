require_dependency 'sivel2_gen/concerns/controllers/casos_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module CasosController
        extend ActiveSupport::Concern

        include Sivel2Gen::Concerns::Controllers::CasosController

        included do
          # Las sisguientes deben estar solo en la clase final
          #before_action :set_caso, only: [:show, :edit, :update, :destroy]
          #load_and_authorize_resource class: Sivel2Gen::Caso
          # Tuve que repetir las siguientes que tambien estan en 
          # Sivel2Gen::Concerns::Controllers::CasosController 
          # pero que no son llamadas 
#          helper Msip::UbicacionHelper

#          def atributos_show
#            [
#              # basicos
#              :id,
#              :fecharec,
#              :oficina,
#              :fecha,
#              :memo,
#              :created_at,
#              :asesor,
#              :contacto,
#              :direccion,
#              :telefono,
#              :atenciones
#            ]
#          end
#
#          # Campos en filtro
#          def campos_filtro1
#            [:codigo,
#              :fechaini, :fechafin, 
#              :fecharecini, :fecharecfin,
#              :departamento_id,
#              :oficina_id, :nusuario,
#              :ultimaatencion_fechaini, :ultimaatencion_fechafin,
#              :statusmigratorio_id,
#              :nombressp, :apellidossp,
#              :nombres, :apellidos, :sexo, :rangoedad_id, 
#              :categoria_id,
#              :descripcion
#            ]
#          end
#
#          # Campos por presentar en listado index
#          def incluir_inicial
#            ['casoid', 'contacto', 'fecharec', 'oficina', 
#              'nusuario', 'fecha', 'statusmigratorio',
#              'ultimaatencion_fecha', 'memo'
#            ]
#          end
#
#
#          # Ordenamiento inicial por este campo
#          def campoord_inicial
#            'fecharec'
#          end
#
#          def cortamemo
#            200
#          end
#
#          def inicializa_index
#            @plantillas = Heb412Gen::Plantillahcm.
#              where(vista: 'Caso').select('nombremenu, id').map { 
#              |c| [c.nombremenu, c.id] 
#            }
#            if defined?(::Ability::ROLINV) && 
#                current_usuario.rol == ::Ability::ROLINV
#              m = current_usuario.etiqueta.map(&:id)
#              if m == []
#                @conscaso = @conscaso.where(FALSE)
#              else
#                @conscaso = @conscaso.
#                  where("caso_id IN (SELECT caso_id FROM 
#                        public.sivel2_gen_caso_etiqueta WHERE
#                        sivel2_gen_caso_etiqueta.etiqueta_id IN 
#                          (#{m.join(',')}))")
#              end
#            end
#          end
#
#          # Filtro adicional para autenticar usado por index
#          def filtro_particular(conscaso, params_filtro)
#            conscaso
#          end

#          # GET /casos/1
#          # GET /casos/1.json
#          def show
#            # En models/ability.rb agregar
#            # can :read, Sivel2Gen::Caso,  etiqueta: { id: usuario.etiqueta.map(&:id) } 
#            if current_usuario.rol == Ability::ROLINV
#              ace = @caso.caso_etiqueta.map { |ce| ce.etiqueta_id }
#              aeu = current_usuario.etiqueta_usuario.map { |eu| eu.etiqueta_id }
#              ie = ace & aeu
#              if (ie.size == 0)
#                raise CanCan::AccessDenied.new("Invitado no autorizado!", :read, Caso)
#              end
#            end
#            show_sivel2_gen
#          end
#
#          # GET /casos/new
#          def new
#            @registro = @caso = Sivel2Gen::Caso.new
#            new_sivel2_sjr
#            redirect_to edit_caso_path(@registro)
#          end

#          def new_sivel2_sjr
#            @caso.current_usuario = current_usuario
#            @caso.fecha = DateTime.now.strftime('%Y-%m-%d')
#            @caso.memo = ''
#            @caso.casosjr = Sivel2Sjr::Casosjr.new
#            @caso.casosjr.fecharec = DateTime.now.strftime('%Y-%m-%d')
#            @caso.casosjr.asesor = current_usuario.id
#            @caso.casosjr.oficina_id= current_usuario.oficina_id.nil? ?  
#              1 : current_usuario.oficina_id
#            if params[:contacto] && 
#              Msip::Persona.where(id: params[:contacto].to_i).count == 1
#              per = Msip::Persona.find(params[:contacto])
#            else
#              per = Msip::Persona.new
#              per.nombres = ''
#              per.apellidos = ''
#              per.sexo = 'S'
#              per.save!(validate: false)
#            end
#            vic = Sivel2Gen::Victima.new
#            vic.persona = per
#            @caso.victima<<vic
#            @caso.casosjr.contacto = per
#            @caso.save!(validate: false)
#            vic.caso_id = @caso.id
#            vic.save!(validate: false)
#            logger.debug "Victima salvada: #{vic.inspect}"
#            #debugger
#            vic.victimasjr = Sivel2Sjr::Victimasjr.new
#            vic.victimasjr.victima_id = vic.id
#            vic.victimasjr.save!(validate: false)
#            cu = Sivel2Gen::CasoUsuario.new
#            cu.usuario_id = current_usuario.id
#            cu.caso_id = @caso.id
#            cu.fechainicio = DateTime.now.strftime('%Y-%m-%d')
#            cu.save!(validate: false)
#          end
#
          def self.asegura_camposdinamicos(
            registro, currente_usuario_id)
          end

#          def edit_sivel2_sjr
#            @caso = @registro = Sivel2Gen::Caso.find(params[:id])
#            authorize! :edit, @registro
#            self.class.asegura_camposdinamicos(
#              @registro, current_usuario.id)
#            @registro.save!(validate: false)
#          end
#
#          # GET /casos/1/edit
#          def edit
#            edit_sivel2_sjr
#            if Cor1440Gen::Proyectofinanciero.where(id: 10).count == 1 then
#              idseg = Cor1440Gen::Actividadpf.where(
#                proyectofinanciero_id: 10,
#                titulo: 'SEGUIMIENTO A CASO')
#              if idseg.count == 1
#                idseg = idseg.take.id
#              else
#                flash[:error] = 'No se identifico actividad de convenio SEGUIMIENTO A CASO'
#                idseg = -1
#              end   
#              @actividadpf_seguimiento_id = idseg
#            end
#            if session[:capturacaso_acordeon]
#              render 'editv', layout: 'application'
#            else
#              render 'edit', layout: 'application'
#            end
#          end
#
#          def validar_params
#            return true
#          end
#
#          def update_sivel2_sjr
#            @casovalido = true if @casovalido.nil? 
#            # No deben venir validaciones en controlador
#            respond_to do |format|
#              if (!params[:caso][:caso_etiqueta_attributes].nil?)
#                params[:caso][:caso_etiqueta_attributes].each {|k,v|
#                  if (v[:usuario_id].nil? || v[:usuario_id] == "") 
#                    v[:usuario_id] = current_usuario.id
#                  end
#                }
#              end
#              if (!params[:caso][:respuesta_attributes].nil?)
#                params[:caso][:respuesta_attributes].each {|k,v|
#                  if (v[:caso_id].nil?) 
#                    v[:caso_id] = @caso.id
#                  end
#                }
#              end
#              @caso.current_usuario = current_usuario
#              @caso.assign_attributes(caso_params)
#              @casovalido &= @caso.valid?
#              @caso.save(validate: false)
#              if registrar_en_bitacora
#                Msip::Bitacora.agregar_actualizar(
#                  request, :caso, :bitacora_cambio, 
#                  current_usuario.id, params, 'Sivel2Gen::Caso',
#                  @caso.id
#                )
#              end
#              if validar_params && @casovalido 
#                format.html { 
#                  if request.xhr?
#                    if request.params[:siguiente] == 'edit'
#                      render(action: 'edit', 
#                             layout: 'application', 
#                             notice: 'Caso actualizado.')
#                    else
#                      render(action: 'show', 
#                             layout: 'application', 
#                             notice: 'Caso actualizado.')
#                    end
#                  else
#                    redirect_to @caso, notice: 'Caso actualizado.'
#                  end
#                }
#                format.json { 
#                  head :no_content 
#                }
#                format.js   { 
#                  redirect_to @caso, notice: 'Caso actualizado.' 
#                }
#                Sivel2Gen::Conscaso.refresca_conscaso
#              else
#                format.html { render action: 'edit', layout: 'application' }
#                format.json { render json: @caso.errors, status: :unprocessable_entity }
#                format.js   { render action: 'edit' }
#              end
#            end
#          end
#
#          # PATCH/PUT /casos/1
#          # PATCH/PUT /casos/1.json
#          def update
#            update_sivel2_sjr
#          end

#          # DELETE /casos/1.json
#          # Este método obligó a definir sivel2_gen_destroy en sivel2_gen/concerns/controllers/casos_controllers
#          # y a repetir before_action :set_caso, only: [:show, :edit, :update, :destroy]
#          # en el included do de este
#          def sivel2_sjr_destroy
#            if @caso.casosjr && @caso.casosjr.respuesta
#              # No se logró hacer ni con dependente:destroy en
#              # las relaciones ni borrando con delete 
#              @caso.casosjr.respuesta.each do |r|
#                Sivel2Sjr::AslegalRespuesta.where(respuesta_id: r.id).delete_all
#                #r.aslegal_respuesta.delete
#                Sivel2Sjr::AyudaestadoRespuesta.where(respuesta_id: r.id).delete_all
#                #r.ayudaestado_respuesta.delete
#                Sivel2Sjr::AyudasjrRespuesta.where(respuesta_id: r.id).delete_all
#                #r.ayudasjr_respuesta.delete
#                Sivel2Sjr::DerechoRespuesta.where(respuesta_id: r.id).delete_all
#                #r.derecho_respuesta.delete
#                Sivel2Sjr::MotivosjrRespuesta.where(respuesta_id: r.id).delete_all
#                #r.motivosjr_respuesta.delete
#                Sivel2Sjr::ProgestadoRespuesta.where(respuesta_id: r.id).delete_all
#                #r.progestado_respuesta.delete
#              end
#              @caso.casosjr.respuesta.delete
#              Sivel2Sjr::Respuesta.where(caso_id: @caso.id).delete_all
#            end
#            Sivel2Sjr::Casosjr.connection.execute <<-SQL
#              DELETE FROM sivel2_sjr_actosjr 
#                WHERE acto_id IN (SELECT id FROM sivel2_gen_acto 
#                  WHERE caso_id='#{@caso.id}');
#              DELETE FROM sivel2_sjr_desplazamiento 
#                WHERE caso_id = #{@caso.id};
#            SQL
#            @caso.casosjr.destroy if @caso.casosjr
#            if @caso.casosjr && @caso.casosjr.errors.present?
#              mens = 'No puede borrar caso: ' + @caso.casosjr.errors.messages.values.flatten.join('; ')
#              puts mens
#              redirect_to caso_path(@caso), alert: mens
#              return
#            else
#              sivel2_gen_destroy
#              Sivel2Gen::Conscaso.refresca_conscaso
#            end
#          end
#
#          def destroy
#            sivel2_sjr_destroy
#          end
#
#          # API, retorna población por sexo y rango de edad (sin modificar
#          # base de datos)
#          def poblacion_sexo_rangoedadac
#            caso_id = params[:caso_id].to_i
#            fecha = Msip::FormatoFechaHelper.fecha_local_estandar(
#              params[:fecha])
#            if !fecha
#              render json: "No se pudo convertir fecha #{params[:fecha]}",
#                status: :unprocessable_entity 
#              return
#            end
#            fecha = Date.strptime(fecha, '%Y-%m-%d')
#
#            anio = fecha.year
#            mes = fecha.month
#            dia = fecha.day
#            casosjr = Sivel2Sjr::Casosjr.where(caso_id: caso_id)
#            if casosjr.count == 0
#              render json: "No se encontró caso #{caso_id}",
#                status: :unprocessable_entity 
#              return
#            end
#            rangoedad = {'S' => {}, 'M' => {}, 'F' => {}}
#            totsexo = {}
#            Sivel2Sjr::RangoedadHelper.poblacion_por_sexo_rango(
#              casosjr.take.caso_id, fecha.year, fecha.month, fecha.day,
#              'Cor1440Gen::Rangoedadac', rangoedad, totsexo)
#            render json: rangoedad, status: :ok
#          end
#
#
#          def busca
#            if !params[:term]
#              respond_to do |format|
#                format.html { render inline: 'Falta variable term' }
#                format.json { render inline: 'Falta variable term' }
#              end
#            else
#              debugger
#              term = Sivel2Gen::Caso.connection.quote_string(params[:term])
#              consNom = term.downcase.strip #sin_tildes
#              consNom.gsub!(/ +/, ":* & ")
#              if consNom.length > 0
#                consNom += ":*"
#              end
#              where = " to_tsvector('spanish', caso_id " +
#                " || ' ' || unaccent(persona.nombres) " +
#                " || ' ' || unaccent(persona.apellidos) " +
#                " || ' ' || COALESCE(msip_tdocumento.sigla, '') " +
#                " || ' ' || COALESCE(persona.numerodocumento::TEXT, '')) @@ " +
#                "to_tsquery('spanish', '#{consNom}')";
#
#              partes = [
#                'caso_id::TEXT',
#                'nombres',
#                'apellidos',
#                'COALESCE(msip_tdocumento.sigla, \'\')',
#                'COALESCE(numerodocumento::TEXT, \'\')'
#              ]
#              s = "";
#              l = " caso_id ";
#              seps = "";
#              sepl = " || ';' || ";
#              partes.each do |p|
#                s += seps + p;
#                l += sepl + "char_length(#{p})";
#                seps = " || ' ' || ";
#              end
#              qstring = "SELECT TRIM(#{s}) AS value, #{l} AS id 
#                FROM public.msip_persona AS persona
#                JOIN sivel2_sjr_casosjr AS casosjr ON 
#                  persona.id=casosjr.contacto_id
#                LEFT JOIN msip_tdocumento ON
#                  persona.tdocumento_id=msip_tdocumento.id
#                WHERE #{where} ORDER BY 1";
#
#              #byebug
#              r = ActiveRecord::Base.connection.select_all qstring
#              respond_to do |format|
#                format.json { render :json, inline: r.to_json }
#                format.html { 
#                  render :json, inline: 'No responde con parametro term' 
#                }
#              end
#            end
#
#            return
#              # autocomplete de jquery requiere label, val
##              consc = ActiveRecord::Base.send(:sanitize_sql_array, ["
##                SELECT label, value FROM (
##                  SELECT label, value, to_tsvector('spanish', unaccent(label)) AS i
##                  FROM (SELECT caso_id || ' ' || nombres || ' ' || 
##                    apellidos || ' ' || numerodocumento as label, 
##                    caso_id as value FROM sivel2_sjr_casosjr JOIN msip_persona ON 
##                      msip_persona.id=sivel2_sjr_casosjr.contacto_id) AS s) as ss 
##                WHERE i @@ to_tsquery('spanish', ?) ORDER BY 1;",
##                consNom
##              ])
##              r = ActiveRecord::Base.connection.select_all consc
##              respond_to do |format|
##                format.json { render :json, inline: r.to_json }
##              end
##            end
#          end
#
#
#          # GET casos/mapaosm
#          def mapaosm
#            @fechadesde = Msip::FormatoFechaHelper.inicio_semestre(Date.today - 182)
#            @fechahasta = Msip::FormatoFechaHelper.fin_semestre(Date.today - 182)
#            render 'sivel2_gen/casos/mapaosm', layout: 'application'
#          end
#
#
#          def set_caso
#            @caso = Sivel2Gen::Caso.find(params[:id].to_i)
#            @caso.current_usuario = current_usuario
#            @registro = @caso
#            pcs = Sivel2Sjr::Casosjr.where(caso_id: params[:id].to_i)
#            @casosjr = nil
#            if pcs.count > 0
#              @casosjr = pcs.take
#            end
#          end
#
#
#          def otros_params
#            []
#          end
#
#          def otros_params_casosjr
#            []
#          end
#
#          def otros_params_victima
#            []
#          end
#
#          def otros_params_victimasjr
#            []
#          end
#
#          def otros_params_respuesta
#            []
#          end
#
#          def otros_params_persona
#            []
#          end
#
#          def desplazamiento_params
#            [
#              :desplazamiento_attributes => [
#                :acompestado, 
#                :connacionaldeportado,
#                :connacionalretorno,
#                :declaro, 
#                :descripcion, 
#                :documentostierra,
#                :fechadeclaracion,
#                :fechadeclaracion_localizada,
#                :fechaexpulsion, 
#                :fechaexpulsion_localizada, 
#                :fechallegada, 
#                :fechallegada_localizada, 
#                :hechosdeclarados,
#                :id, 
#                :acreditacion_id, 
#                :clasifdesp_id, 
#                :declaroante_id, 
#                :expulsion_id, 
#                :inclusion_id,
#                :llegada_id, 
#                :modalidadtierra_id,
#                :tipodesp_id, 
#                :inmaterialesperdidos,
#                :materialesperdidos, 
#                :protegiorupta, 
#                :oficioantes, 
#                :otrosdatos,
#                :retornado,
#                :reubicado, 
#                :_destroy,
#                :categoria_ids => []
#              ]
#            ]
#          end
#
#
#          def lista_params
#            lp = [
#              :bienes, 
#              :duracion, 
#              :fecha, 
#              :fecha_localizada, 
#              :grconfiabilidad, 
#              :gresclarecimiento, 
#              :grimpunidad, 
#              :grinformacion, 
#              :hora, 
#              :id, 
#              :intervalo_id, 
#              :memo, 
#              :titulo, 
#              :casosjr_attributes => [
#                :asesor, 
#                :comosupo_id, 
#                :contacto, 
#                :concentimientosjr, 
#                :concentimientobd,
#                :categoriaref,
#                :dependen, 
#                :detcomosupo,
#                :direccion, 
#                :docrefugiado,
#                :estatus_refugio,
#                :estrato, 
#                :fecharec, 
#                :fecharec_localizada, 
#                :fechadecrefugio,
#                :fechadecrefugio_localizada,
#                :fechallegada, 
#                :fechallegada_localizada, 
#                :fechallegadam, 
#                :fechallegadam_localizada, 
#                :fechasalida, 
#                :fechasalida_localizada, 
#                :fechasalidam, 
#                :fechasalidam_localizada, 
#                :gastos, 
#                :ingresomensual, 
#                :id, 
#                :idioma_id,
#                :llegada_id, 
#                :llegada_idm, 
#                :proteccion_id, 
#                :salida_id, 
#                :salida_idm, 
#                :estatusmigratorio_id,
#                :leerescribir, 
#                :memo1612,
#                :motivom,
#                :observacionesref,
#                :oficina_id, 
#                :sustento, 
#                :telefono, 
#                :_destroy
#              ] + otros_params_casosjr, 
#              :victima_attributes => [
#                :anotaciones,
#                :id, 
#                :etnia_id, 
#                :filiacion_id, 
#                :iglesia_id, 
#                :organizacion_id, 
#                :persona_id, 
#                :profesion_id, 
#                :rangoedad_id, 
#                :vinculoestado_id, 
#                :orientacionsexual, 
#                :_destroy 
#              ] + otros_params_victima + [
#                :persona_attributes => [
#                  :apellidos, 
#                  :anionac, 
#                  :dianac, 
#                  :id, 
#                  :pais_id, 
#                  :departamento_id, 
#                  :municipio_id, 
#                  :clase_id, 
#                  :mesnac, 
#                  :nacionalde, 
#                  :numerodocumento, 
#                  :nombres, 
#                  :sexo, 
#                  :tdocumento_id
#                ] + otros_params_persona,
#                :victimasjr_attributes => [
#                  :asisteescuela, 
#                  :cabezafamilia, 
#                  :enfermedad, 
#                  :eps, 
#                  :fechadesagregacion,
#                  :fechadesagregacion_localizada,
#                  :id, 
#                  :victima_id, 
#                  :rolfamilia_id,
#                  :actividadoficio_id, 
#                  :escolaridad_id,
#                  :estadocivil_id, 
#                  :maternidad_id, 
#                  :regimensalud_id, 
#                  :ndiscapacidad, 
#                  :sindocumento, 
#                  :tienesisben
#                ] + otros_params_victimasjr 
#              ], 
#              :ubicacion_attributes => [
#                :id, 
#                :clase_id, 
#                :departamento_id, 
#                :municipio_id, 
#                :pais_id, 
#                :tsitio_id, 
#                :latitud, 
#                :longitud, 
#                :lugar, 
#                :sitio, 
#                :_destroy
#              ],
#              :caso_presponsable_attributes => [
#                :batallon, 
#                :bloque, 
#                :brigada, 
#                :division, 
#                :frente, 
#                :id, 
#                :presponsable_id, 
#                :otro, 
#                :tipo, 
#                :_destroy
#              ],
#              :acto_attributes => [
#                :id, 
#                :categoria_id, 
#                :presponsable_id, 
#                :persona_id, 
#                :_destroy,
#                :actosjr_attributes => [
#                  :desplazamiento_id, 
#                  :fecha, 
#                  :fecha_localizada, 
#                  :id, 
#                  :acto_id, 
#                  :_destroy
#                ]
#              ],
#              :respuesta_attributes => [
#                :accionesder,
#                :cantidadayes,
#                :compromisos,
#                :detalleal, 
#                :detalleap, 
#                :detalleem, 
#                :detallemotivo, 
#                :detallear, 
#                :descatencion,
#                :descamp, 
#                :difobsprog,
#                :efectividad, 
#                :id,
#                :persona_iddesea, 
#                :informacionder, 
#                :institucionayes, 
#                :fechaatencion, 
#                :fechaatencion_localizada, 
#                :fechaultima, 
#                :fechaultima_localizada, 
#                :gestionessjr, 
#                :lugar, 
#                :lugarultima, 
#                :montoal,
#                :montoap,
#                :montoar,
#                :montoem,
#                :montoprorrogas,
#                :numprorrogas, 
#                :observaciones,
#                :orientaciones, 
#                :remision,  
#                :turno,
#                :verifcsjr, 
#                :verifcper,
#                :_destroy, 
#                :aslegal_ids => [],
#                :aspsicosocial_ids => [],
#                :ayudaestado_ids => [],
#                :ayudasjr_ids => [],
#                :derecho_ids => [],
#                :emprendimiento_ids => [],
#                :motivosjr_ids => [],
#                :progestado_ids => [],
#              ] + otros_params_respuesta,
#              :anexo_caso_attributes => [
#                :fecha_localizada,
#                :id, 
#                :caso_id,
#                :_destroy,
#                :msip_anexo_attributes => [
#                  :adjunto, 
#                  :descripcion, 
#                  :id, 
#                  :_destroy
#                ]
#              ],
#              :caso_etiqueta_attributes => [
#                :fecha, 
#                :id, 
#                :etiqueta_id, 
#                :usuario_id, 
#                :observaciones, 
#                :_destroy
#              ]
#           ] + otros_params  + desplazamiento_params
#
#            lp
#          end
#
#          private
#
#          # Never trust parameters from the scary internet, only allow the white list through.
#          def caso_params
#            lp = lista_params 
#            params.require(:caso).permit(lp)
#          end

        end

      end
    end
  end
end
