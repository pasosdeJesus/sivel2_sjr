# encoding: UTF-8
module Sivel2Sjr
  class CasosController < ApplicationController
    before_action :set_caso, only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: Sivel2Gen::Caso

    # GET /casos
    # GET /casos.json
    def index
      Caso.refresca_conscaso
      q=params[:q]
      if (q && q.strip.length>0)
        @conscaso = Conscaso.where(
          "q @@ plainto_tsquery('spanish', unaccent(?))", q
        )
      else
        @conscaso = Conscaso.all
      end
      if (current_usuario.rol == Ability::ROLINV) 
        @conscaso= @conscaso.where(
          "caso_id IN (SELECT id_caso FROM caso_etiqueta, etiqueta_usuario 
          WHERE caso_etiqueta.id_etiqueta=etiqueta_usuario.etiqueta_id
          AND etiqueta_usuario.usuario_id ='" + 
          current_usuario.id.to_s + "')")
      end
      @numconscaso = @conscaso.size
      @conscaso = @conscaso.order(fecharec: :desc).paginate(:page => params[:pagina], per_page: 20)
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
    end

    # GET /casos/new
    def new
      @caso.current_usuario = current_usuario
      @caso.fecha = DateTime.now.strftime('%Y-%m-%d')
      @caso.memo = ''
      @caso.casosjr = Casosjr.new
      @caso.casosjr.fecharec = DateTime.now.strftime('%Y-%m-%d')
      @caso.casosjr.asesor = current_usuario.id
      @caso.casosjr.id_regionsjr = current_usuario.regionsjr_id.nil? ?  
        1 : current_usuario.regionsjr_id
      per = Persona.new
      per.nombres = ''
      per.apellidos = ''
      per.sexo = 'S'
      per.save!(validate: false)
      vic = Victima.new
      vic.persona = per
      @caso.victima<<vic
      @caso.casosjr.contacto = per
      @caso.save!(validate: false)
      vic.id_caso = @caso.id
      vic.save!(validate: false)
      logger.debug "Victima salvada: #{vic.inspect}"
      #debugger
      vic.victimasjr = Victimasjr.new
      vic.victimasjr.id_victima = vic.id
      vic.victimasjr.save!(validate: false)
      cu = CasoUsuario.new
      cu.id_usuario = current_usuario.id
      cu.id_caso = @caso.id
      cu.fechainicio = DateTime.now.strftime('%Y-%m-%d')
      cu.save!(validate: false)
      render action: 'edit'
    end

    def lista
      if !params[:tabla].nil?
        r = nil

        if (params[:tabla] == "departamento" && params[:id_pais].to_i > 0)
          r = Departamento.where(fechadeshabilitacion: nil,
                                 id_pais: params[:id_pais].to_i).order(:nombre)
        elsif (params[:tabla] == "municipio" && params[:id_pais].to_i > 0 && 
               params[:id_departamento].to_i > 0 )
          r = Municipio.where(id_pais: params[:id_pais].to_i, 
                              id_departamento: params[:id_departamento].to_i,
                              fechadeshabilitacion: nil).order(:nombre)
        elsif (params[:tabla] == "clase" && params[:id_pais].to_i > 0 && 
               params[:id_departamento].to_i > 0 && 
               params[:id_municipio].to_i > 0)
          r = Clase.where(id_pais: params[:id_pais].to_i, 
                          id_departamento: params[:id_departamento].to_i, 
                          id_municipio: params[:id_municipio].to_i,
                          fechadeshabilitacion: nil).order(:nombre)
        end
        respond_to do |format|
          format.js { render json: r }
          format.html { render json: r }
        end
        return
      end
      respond_to do |format|
        format.html { render inline: 'No' }
      end
    end


    # GET /casos/1/edit
    def edit
    end

    # POST /casos
    # POST /casos.json
    def create
      @caso.current_usuario = current_usuario
      @caso.memo = ''
      @caso.titulo = ''

      respond_to do |format|
        if @caso.save
          format.html { redirect_to @caso, notice: 'Caso creado.' }
          format.json { render action: 'show', status: :created, location: @caso }
        else
          format.html { render action: 'new' }
          format.json { render json: @caso.errors, status: :unprocessable_entity }
        end
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
          format.html { render action: 'edit' }
          format.json { render json: @caso.errors, status: :unprocessable_entity }
          format.js   { render action: 'edit' }
        end
      end
    end

    # DELETE /casos/1
    # DELETE /casos/1.json
    def destroy
      @caso.casosjr.destroy if !@caso.casosjr.nil?
      @caso.destroy
      respond_to do |format|
        format.html { redirect_to casos_url }
        format.json { head :no_content }
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_caso
      @caso = Caso.find(params[:id])
      @caso.current_usuario = current_usuario
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def caso_params
      params.require(:caso).permit(
        :id, :titulo, :fecha, :hora, :duracion, 
        :grconfiabilidad, :gresclarecimiento, :grimpunidad, :grinformacion, 
        :bienes, :id_intervalo, :memo, 
        :casosjr_attributes => [
          :id, :fecharec, :asesor, :id_regionsjr, :direccion, 
          :telefono, :comosupo_id, :contacto, :detcomosupo,
          :dependen, :sustento, :leerescribir, 
          :ingresomensual, :gastos, :estrato, :id_statusmigratorio,
          :id_proteccion, :id_idioma,
          :concentimientosjr, :concentimientobd,
          :fechasalida, :id_salida, 
          :fechallegada, :id_llegada, 
          :categoriaref,
          :observacionesref,
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
          :_destroy
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
      :anexo_attributes => [
        :id, :fecha, :descripcion, :archivo, :adjunto, :_destroy
      ],
        :caso_etiqueta_attributes => [
          :id, :id_usuario, :fecha, :id_etiqueta, :observaciones, :_destroy
      ]
      )
    end
  end
end
