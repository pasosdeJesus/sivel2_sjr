# encoding: UTF-8
module Sivel2Sjr
  class CasosController < Sivel2Gen::CasosController

    # GET /casos
    # GET /casos.json
    def index
      Sivel2Gen::Conscaso.refresca_conscaso

      @incluir = ['casoid', 'contacto', 'fecharec', 'oficina', 
                  'nusuario', 'fecha', 'statusmigratorio',
                  'ultimafechaatencion', 'memo'
      ]
      @campoord = 'fecharec'
      @conscaso = Sivel2Gen::Conscaso.all
      if params && params[:filtro]
        if params[:filtro][:q] && params[:filtro][:q].length>0
          q = params[:filtro][:q].gsub("-", " ")
          @conscaso = @conscaso.where(
            "q @@ plainto_tsquery('spanish', unaccent(?))", q
          )
        end
        @conscaso = filtro_avanzado @conscaso, params[:filtro]
        if params[:filtro][:orden]
         @campoord = params[:filtro][:orden]
        end
        nincluir = []
        for i in @incluir do
          s = 'inc_' + i
          if params[:filtro][s.to_sym] && params[:filtro][s.to_sym] == '1'
            nincluir.push(i)
          end
        end
        @incluir = nincluir
      end
      if (current_usuario.rol == Ability::ROLINV) 
        @conscaso= @conscaso.where(
          "caso_id IN (SELECT id_caso FROM 
          sivel2_gen_caso_etiqueta AS caso_etiqueta, 
          sivel2_sjr_etiqueta_usuario AS etiqueta_usuario 
          WHERE caso_etiqueta.id_etiqueta=etiqueta_usuario.etiqueta_id
          AND etiqueta_usuario.usuario_id ='" + 
          current_usuario.id.to_s + "')")
      end
      @conscaso = @conscaso.ordenar_por @campoord
      @numconscaso = @conscaso.size
      @paginar = !params || !params[:filtro] || !params[:filtro][:paginar] ||
        params[:filtro][:paginar] != '0'
      if @paginar
        @conscaso = @conscaso.paginate(page: params[:pagina], per_page: 20)
      end
      respond_to do |format|
        format.html { render layout: 'application' }
        format.js { render 'sivel2_gen/casos/filtro' }
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

    # DELETE /casos/1
    # DELETE /casos/1.json
    def destroy
      @caso.casosjr.destroy if @caso.casosjr
      super
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def caso_params
      params.require(:caso).permit(
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
      )
    end
  end
end
