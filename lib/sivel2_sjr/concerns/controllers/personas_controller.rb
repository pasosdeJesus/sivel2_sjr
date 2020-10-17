# encoding: UTF-8

require 'sivel2_gen/concerns/controllers/personas_controller'
require 'cor1440_gen/concerns/controllers/personas_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module PersonasController
        extend ActiveSupport::Concern

        included do

          include Sivel2Gen::Concerns::Controllers::PersonasController
          include Cor1440Gen::Concerns::Controllers::PersonasController

          def atributos_show_sivel2_sjr
            a = atributos_show_sip - [
              :mesnac, 
              :dianac
            ] + [ 
              :caso_ids, 
              :actividad_ids, 
              :actividadcasobeneficiario_ids 
            ]
            a[a.index(:anionac)] = :fechanac 
            a
          end

          def atributos_show
            atributos_show_sivel2_sjr
          end

          def atributos_index_sivel2_sjr
            [ :id, 
              :nombres,
              :apellidos,
              :tdocumento,
              :numerodocumento,
              :fechanac,
              :sexo,
              :municipio,
              :actividad_ids,
              :actividadcasobeneficiario_ids
            ]
          end

          def atributos_index
            atributos_index_sivel2_sjr
          end

          def atributos_form_sivel2_sjr
            a = atributos_show - [
              :id, 
              :caso_ids, 
              :actividad_ids, 
              :actividadcasobeneficiario_ids
            ] + [
              :caracterizaciones
            ]
            # Cambia fechanac por dia, mes, año
            p = a.index(:fechanac)
            a[p] = :anionac
            a.insert(p, :mesnac)
            a.insert(p, :dianac)
            return a
          end

          def atributos_form
            atributos_form_sivel2_sjr
          end

          def vistas_manejadas
            ['Persona']
          end

          # Busca y lista persona(s)

          def index(c = nil)
            if c == nil
              c = Sip::Persona.all
            end
            if params[:term]
              term = Sivel2Gen::Caso.connection.quote_string(params[:term])
              consNomvic = term.downcase.strip #sin_tildes
              consNomvic.gsub!(/ +/, ":* & ")
              if consNomvic.length > 0
                consNomvic += ":*"
              end
              where = " to_tsvector('spanish', unaccent(persona.nombres) " +
                " || ' ' || unaccent(persona.apellidos) " +
                " || ' ' || COALESCE(persona.numerodocumento::TEXT, '')) @@ " +
                "to_tsquery('spanish', '#{consNomvic}')";

              partes = [
                'nombres',
                'apellidos',
                'COALESCE(numerodocumento::TEXT, \'\')'
              ]
              s = "";
              l = " persona.id ";
              seps = "";
              sepl = " || ';' || ";
              partes.each do |p|
                s += seps + p;
                l += sepl + "char_length(#{p})";
                seps = " || ' ' || ";
              end
              qstring = "SELECT TRIM(#{s}) AS value, #{l} AS id " +
                "FROM public.sip_persona AS persona " +
                "WHERE #{where} ORDER BY 1"
              r = ActiveRecord::Base.connection.select_all qstring
              respond_to do |format|
                format.json { render :json, inline: r.to_json }
                format.html { render :json, inline: 'No responde con parametro term' }
              end
            else
              super(c)
            end
          end

          def remplazar_antes_salvar_v
            ce = Sivel2Sjr::Casosjr.where(contacto: @persona.id)
            if ce.count > 0
              render json: "Ya es contacto en el caso #{ce.take.id_caso}.",
                status: :unprocessable_entity
              return false
            end
            ve = Sivel2Sjr::Victimasjr.joins('JOIN sivel2_gen_victima ' +
              ' ON sivel2_gen_victima.id = sivel2_sjr_victimasjr.id_victima').
              where('sivel2_gen_victima.id_persona' => @persona.id).
              where(fechadesagregacion: nil)
            if ve.count > 0
              render json: "Está en núcleo familiar sin desagregar " +
                "en el caso #{ve.take.victima.id_caso}", 
                status: :unprocessable_entity
              return false
            end
            if @caso.casosjr.contacto 
              if @caso.casosjr.contacto.nombres != ""
                render json: "Ya hay una persona asociada, no es posible remplazar",
                  status: :unprocessable_entity
              else
                ppb=@caso.casosjr.contacto_id
                @caso.casosjr.contacto_id = nil
                @caso.casosjr.save!(validate: false)
                vic = @caso.victima.where(id_persona: ppb).take
                vic.id_persona=@persona.id
                vic.save(validate: false)
                @caso.casosjr.contacto_id = @persona.id
                @caso.casosjr.save!(validate: false)
                #redirect_to sivel2_gen.edit_caso_path(@caso)
                return false # buscar obligar el redirect_to
              end
            end

            return true
          end

          def remplazar_despues_salvar_v
            if @caso.casosjr.contacto.id == @personaant.id
              @caso.casosjr.contacto = @persona
              @caso.casosjr.save
              if @caso.validate
                @caso.save
              end
            end
            return true
          end

          def lista_params
            atributos_form + [
              :id_pais,
              :id_departamento,
              :id_municipio,
              :id_clase,
              :tdocumento_id 
            ] + [
              "caracterizacionpersona_attributes" =>
              [ :id,
                "respuestafor_attributes" => [
                  :id,
                  "valorcampo_attributes" => [
                    :valor,
                    :campo_id,
                    :id
                  ]
              ] ]
            ] + [
              'proyectofinanciero_ids' => []
            ]
          end

        end # included

      end
    end
  end
end
