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

          def atributos_index
            [ :id, 
              :nombres,
              :apellidos,
              :tdocumento,
              :numerodocumento,
              :fechanac,
              :sexo,
              :municipio
            ]
          end

          def atributos_show
            [ :id, 
              :nombres,
              :apellidos,
              :fechanac,
              :sexo,
              :pais,
              :departamento,
              :municipio,
              :clase,
              :nacionalde,
              :tdocumento,
              :numerodocumento
            ]
          end


          def atributos_form
            a = atributos_show - [:id] + [:caracterizaciones]
            # Cambia fechanac por dia, mes, año
            p = a.index(:fechanac)
            a[p] = :anionac
            a.insert(p, :mesnac)
            a.insert(p, :dianac)
            return a
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
              qstring = "SELECT TRIM(#{s}) AS value, #{l} AS id 
        FROM public.sip_persona AS persona
        WHERE #{where} ORDER BY 1";

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
            byebug
          end

          def remplazar_despues_salvar_v
            if @caso.casosjr.contacto.id == @personaant.id
              @caso.casosjr.contacto = @persona
              @caso.casosjr.save
              if @caso.validate
                @caso.save
              end
            end
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
