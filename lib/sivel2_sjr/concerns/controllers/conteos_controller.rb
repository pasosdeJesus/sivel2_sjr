
require_dependency 'sivel2_gen/concerns/controllers/conteos_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module ConteosController
        extend ActiveSupport::Concern

        include Sivel2Gen::Concerns::Controllers::ConteosController

        included do

          def respuestas_que
            return [{ 
              'aslegal' => 'Asistencia Legal del SJR',
              'ayudasjr' => 'Ayuda Humanitaria del SJR',
            }, 'aslegal', 'Servicios Prestados']
          end

          def respuestas
            authorize! :contar, Sivel2Gen::Caso
            @pque, pContarDef, @titulo_respuesta = respuestas_que

            pFaini = escapar_param(params, [:filtro, 'fechaini'])
            pFafin = escapar_param(params, [:filtro, 'fechafin'])
            pContar = escapar_param(params, [:filtro, 'contar'])
            pOficina = escapar_param(params, [:filtro, 'oficina_id'])

            if (pContar == '') 
              pContar = pContarDef
            end

            personas_cons1 = 'cres1'
            # La estrategia es 
            # 1. Agrupar en la vista personas_cons1 respuesta con lo que se contará 
            #    restringiendo por filtros con códigos 
            # 2. Contar derechos/respuestas personas_cons1, cambiar códigos
            #    por información por desplegar

            # Para la vista personas_cons1 emplear que1, tablas1 y where1
            where1 = ""
            # Para la consulta final emplear arreglo que3, que tendrá parejas
            # (campo, titulo por presentar en tabla)
            que3 = []
            tablas3 = personas_cons1
            where3 = ''

            if (pFaini != '') 
              pfechaini = DateTime.strptime(pFaini, '%Y-%m-%d')
              @fechaini = pfechaini.strftime('%Y-%m-%d')
              where1 = consulta_and(
                where1, "sub.fecha", @fechaini, ">="
              )
            end
            if (pFafin != '') 
              pfechafin = DateTime.strptime(pFafin, '%Y-%m-%d')
              @fechafin = pfechafin.strftime('%Y-%m-%d')
              where1 = consulta_and(
                where1, "sub.fecha", @fechafin, "<="
              )
            end

            if (pOficina != '') 
              where1 = consulta_and(where1, "sub.oficina_id", pOficina)
            end

            id_basica = "id_#{pContar}"
            basica = "sivel2_sjr_#{pContar}"
            basica_id = "#{pContar}_id"
            tablas3 = agrega_tabla(tablas3, "public.sivel2_sjr_#{pContar} AS #{pContar}")
            where3 = consulta_and_sinap(where3, "#{basica_id}::integer", 
                                        "#{pContar}.id")
            que3 << ["#{pContar}.nombre", @pque[pContar]]

            case (pContar) 
            when 'ayudasjr'
              campoid = 110
            when 'ayudaestado'
              campoid = 103
            when 'derecho'
              campoid = 100
            when 'motivosjr'
              campoid = 150
            when 'progestado'
              campoid = 106
            when 'aslegal'
              campoid = 130
            else
              basica = "loca"
              basica_id = "loca_id"
              tabla3 = "local"
              que3 = "loca"
              where3 = "loca"
              puts "opción desconocida #{pContar}"
            end
            where1 += ((where1 == "") ? "" : " AND ") + 
              "sub.#{basica_id} IS NOT NULL AND sub.#{basica_id}<>''"

            begin
              ActiveRecord::Base.connection.execute(
                "DROP MATERIALIZED VIEW  IF EXISTS #{personas_cons1}"
              )
            rescue 
              begin
                ActiveRecord::Base.connection.execute(
                  "DROP VIEW  IF EXISTS #{personas_cons1}"
                )
              rescue 
              end
            end
            que1="sub.actividad_id, sub.fecha, sub.oficina_id, sub.#{basica_id}"
            tablas1="(SELECT DISTINCT a.id AS actividad_id, 
                a.fecha, a.oficina_id, 
                json_array_elements_text(v.valorjson) AS #{basica_id}
              FROM mr519_gen_valorcampo AS v 
              JOIN cor1440_gen_actividad_respuestafor AS ar 
                ON ar.respuestafor_id=v.respuestafor_id 
              JOIN cor1440_gen_actividad AS a
                ON a.id=ar.actividad_id
              WHERE campo_id=#{campoid}) AS sub"

            # Filtrar 
            q1="CREATE MATERIALIZED VIEW #{personas_cons1} AS 
              SELECT #{que1}
              FROM #{tablas1} 
              WHERE #{where1}
            "
            puts "q1 es #{q1}"
            ActiveRecord::Base.connection.execute q1

            #puts que3
            # Generamos 1,2,3 ...n para GROUP BY
            gb = sep = ""
            qc = ""
            i = 1
            que3.each do |t|
              if (t[1] != "") 
                gb += sep + i.to_s
                qc += t[0] + ", "
                sep = ", "
                i += 1
              end
            end

            @coltotales = [i-1, i]
            if (gb != "") 
              gb ="GROUP BY #{gb} ORDER BY #{i} DESC"
            end
            que3 << ["", "Cantidad atenciones"]
            twhere3 = where3 == "" ? "" : "WHERE " + where3
            q3 = "SELECT #{qc}
              COUNT(cast(#{personas_cons1}.actividad_id as text) || ' '
              || cast(#{personas_cons1}.fecha as text))
              FROM #{tablas3}
              #{twhere3}
              #{gb} 
            "
            @cuerpotabla = ActiveRecord::Base.connection.select_all(q3)

            @enctabla = []
            que3.each do |t|
              if (t[1] != "") 
                @enctabla << CGI.escapeHTML(t[1])
              end
            end

            respond_to do |format|
              format.html { }
              format.json { head :no_content }
              format.js   { render 'sivel2_sjr/conteos/resultado_respuestas' }
            end
          end # def respuesta
 
          def personas_cons1
            'public.mcben1'
          end

          def personas_cons2
            'public.mcben2'
          end


          def personas_filtros_especializados
            @filtrosegun = personas_arma_filtros()
            @opsegun =  [''] + @filtrosegun.keys
            @titulo_personas = 'Personas atendidas'
            @titulo_personas_fecha = 'Fecha de Recepción'
            @pOficina = escapar_param(params, [:filtro, 'oficina_id'])
          end

          def personas_arma_filtros_sivel2_sjr
            cmesesrecepcion = Sivel2Sjr::Casosjr.all.
              pluck('distinct fecharec').
              map { |f| "#{f.year}-#{f.month.to_s.rjust(2, '0')}"}.uniq.sort

            f = personas_arma_filtros_sivel2_gen
            g = {
              'ACTIVIDAD / OFICIO' => {
                nomfiltro: :actividadesoficios,
                coleccion: Sivel2Gen::Actividadoficio.all.order(:nombre),
                metodo_etiqueta: :nombre,
                metodo_id: :id,
                campocons: 'victimasjr.id_actividadoficio'
              },
              'AÑO DE NACIMIENTO' => f['AÑO DE NACIMIENTO'],
              'CABEZA DE HOGAR' => {
                nomfiltro: :cabezasdehogar,
                coleccion: [['SI', 't'],['NO', 'f']],
                metodo_etiqueta: false,
                metodo_id: false,
                campocons: 'victimasjr.cabezafamilia'
              },
              'ESTADO CIVIL' => {
                nomfiltro: :estadosciviles,
                coleccion: Sivel2Gen::Estadocivil.all.order(:nombre),
                metodo_etiqueta: :nombre,
                metodo_id: :id,
                campocons: 'victimasjr.id_estadocivil'
              },
              'ETNIA' => f['ETNIA'],
              'MES RECEPCIÓN' => {
                nomfiltro: :mesesrecepcion,
                coleccion: cmesesrecepcion.map {|m| [m, m]},
                metodo_etiqueta: false,
                metodo_id: false,
                campocons: "EXTRACT(YEAR FROM casosjr.fecharec)::text || "\
                "'-' || "\
                "LPAD(EXTRACT(MONTH FROM casosjr.fecharec)::text, 2, '0')"
              },
              'NIVEL ESCOLAR' => {
                nomfiltro: :nivelesescolares,
                coleccion: Sivel2Gen::Escolaridad.all.order(:nombre),
                metodo_etiqueta: :nombre,
                metodo_id: :id,
                campocons: 'victimasjr.id_escolaridad'
              },
              'RANGO DE EDAD' => f['RANGO DE EDAD'],
              'SEXO' => f['SEXO']
            }
            return g
          end

          def personas_arma_filtros
            return personas_arma_filtros_sivel2_sjr
          end

          def personas_fecha_inicial(where1)
            consulta_and(
              where1, "casosjr.fecharec", @fechaini, ">="
            )
          end

          def personas_fecha_final(where1)
            return consulta_and(
              where1, "casosjr.fecharec", @fechafin, "<="
            )
          end

          def personas_procesa_filtros(que1, tablas1, where1, que3, tablas3, where3)
            # 2. En vista personas_cons2 dejar lo mismo que en personas_cons1, pero añadiendo
            #    expulsión más reciente y su ubicacion si la hay.
            #    Al añadir info. geográfica no es claro
            #    cual poner, porque un caso debe tener varias ubicaciones 
            #    correspondientes a los sitios por donde ha pasado durante
            #    desplazamientos.  Estamos suponiendo que interesa
            #    el sitio de la ultima expulsion.
            # 3. Contar beneficiarios contactos sobre personas_cons2, cambiar códigos
            #    por información por desplegar
            # 4. Contar beneficiarios no contactos sobre personas_cons2, cambiar códigos
            #    por información por desplegar

            # Validaciones todo caso es casosjr y viceversa

            que1 = 'caso.id AS id_caso, victima.id_persona AS id_persona,
            CASE WHEN (casosjr.contacto_id=victima.id_persona) THEN 1 ELSE 0 END 
            AS contacto, 
            CASE WHEN (casosjr.contacto_id<>victima.id_persona) THEN 1 ELSE 0 END
            AS beneficiario, 
            1 as npersona'
            tablas1 = 'public.sivel2_gen_caso AS caso, ' +
              'public.sivel2_sjr_casosjr AS casosjr, ' +
              'public.sivel2_gen_victima AS victima, ' +
              'public.msip_persona AS persona, ' +
              'public.sivel2_sjr_victimasjr AS victimasjr'

            # Para la consulta final emplear arreglo que3, que tendrá parejas
            # (campo, titulo por presentar en tabla)
            que3 = []
            tablas3 = "#{personas_cons2}"
            where3 = ''

            #    consulta_and(where1, 'caso.id', GLOBALS['idbus'], '<>')
            where1 = consulta_and_sinap(where1, "caso.id", "casosjr.id_caso")
            where1 = consulta_and_sinap(where1, "caso.id", "victima.id_caso")
            where1 = consulta_and_sinap(where1, "persona.id", 
                                        "victima.id_persona")
            where1 = consulta_and_sinap(where1, "victima.id", 
                                        "victimasjr.id_victima")
            where1 = consulta_and_sinap(where1, "victimasjr.fechadesagregacion", 
                                        "NULL", " IS ")
            puts "OJO where1=#{where1}"

            if (@pOficina != '') 
              where1 = consulta_and(where1, "casosjr.oficina_id", @pOficina)
            end
         
            que1, tablas1, where1, que3, tablas3, where3 = 
              personas_procesa_filtros_sivel2_gen(que1, tablas1, where1, 
                                                  que3, tablas3, where3)

            return [que1, tablas1, where1, que3, tablas3, where3] 
          end

          # @param tabla es tabla sin prefijo sivel2_gen
          def personas_segun_tipico_sjr(tabla, nomtabla, que1, tablas1, where1, que3, tablas3, where3)
              que1 = agrega_tabla(
                que1, "victimasjr.id_#{tabla} AS id_#{tabla}")
#              tablas1 = agrega_tabla(
#                tablas1, 'public.sivel2_sjr_victimasjr AS victimasjr')
#              where1 = consulta_and_sinap(
#                where1, "victima.id", "victimasjr.id_victima")
              tablas3 = agrega_tabla(
                tablas3, "public.sivel2_gen_#{tabla} AS #{tabla}")
              where3 = consulta_and_sinap(
                where3, "id_#{tabla}", "#{tabla}.id")
              que3 << ["#{tabla}.nombre", nomtabla]
              return [que1, tablas1, where1, que3, tablas3, where3] 
          end


          def personas_procesa_segun_omsjr(que1, tablas1, where1, que3, tablas3, where3)
            #byebug
            case @pSegun
            when 'ACTIVIDAD / OFICIO'
              que1, tablas1, where1, que3, tablas3, where3 = 
                personas_segun_tipico_sjr(
                  'actividadoficio', 'Actividad/Oficio', que1, tablas1, where1, 
                  que3, tablas3, where3
              )
            when 'CABEZA DE HOGAR'
              que1 = agrega_tabla(
                que1, "CASE WHEN victimasjr.cabezafamilia THEN 
                  'SI'
                ELSE
                  'NO'
                END AS cabezafamilia")
#              tablas1 = agrega_tabla(
#                tablas1, 'public.sivel2_sjr_victimasjr AS victimasjr')
#              where1 = consulta_and_sinap(
#                where1, "victima.id", "victimasjr.id_victima")
              que3 << ["cabezafamilia", "Cabeza de Hogar"]

            when 'ESTADO CIVIL'
              que1, tablas1, where1, que3, tablas3, where3 = 
                personas_segun_tipico_sjr(
                  'estadocivil', 'Estado Civil', que1, tablas1, where1,
                  que3, tablas3, where3
              )

            when 'MES RECEPCIÓN'
              que1 = agrega_tabla(
                que1, "extract(year from fecharec) || '-' " +
                "|| lpad(cast(extract(month from fecharec) as text), 2, " +
                "cast('0' as text)) as mes")
              que3 << ["mes", "Mes"]

            when 'NIVEL ESCOLAR'
              que1, tablas1, where1, que3, tablas3, where3 = 
                personas_segun_tipico_sjr(
                  'escolaridad', 'Nivel Escolar', que1, tablas1, where1,
                  que3, tablas3, where3
              )

            when 'RÉGIMEN DE SALUD'
              que1 = agrega_tabla(
                que1, 'victimasjr.id_regimensalud AS id_regimensalud')
#              tablas1 = agrega_tabla(
#                tablas1, 'public.sivel2_sjr_victimasjr AS victimasjr')
#              where1 = consulta_and_sinap(
#                where1, "victima.id", "victimasjr.id_victima")
              tablas3 = agrega_tabla(
                tablas3, 'public.sivel2_sjr_regimensalud AS regimensalud')
              where3 = consulta_and_sinap(
                where3, "id_regimensalud", "regimensalud.id")
              que3 << ["regimensalud.nombre", "Régimen de Salud"]

            else
              que1, tablas1, where1, que3, tablas3, where3 =
                personas_procesa_segun_om(que1, tablas1, where1, que3, tablas3, where3)
            end
            return [que1, tablas1, where1, que3, tablas3, where3]
          end


          def personas_procesa_segun(que1, tablas1, where1, que3, tablas3, where3)
            return personas_procesa_segun_omsjr(que1, tablas1, where1, que3, tablas3, where3)
          end


          def personas_inicializa1(where1)
            que1 = 'caso.id AS id_caso, victima.id AS id_victima, ' +
              'victima.id_persona AS id_persona, 1 AS npersona'
            tablas1 = 'public.sivel2_gen_caso AS caso, ' +
              'public.sivel2_gen_victima AS victima ' 
            where1 = consulta_and_sinap(where1, "caso.id", "victima.id_caso")
            return que1, tablas1, where1
          end


          def personas_vista_geo(que3, tablas3, where3)
            ActiveRecord::Base.connection.execute(
              "CREATE OR REPLACE MATERIALIZED VIEW  ultimodesplazamiento AS 
            (SELECT sivel2_sjr_desplazamiento.id, s.id_caso, s.fechaexpulsion, 
              sivel2_sjr_desplazamiento.id_expulsion 
              FROM public.sivel2_sjr_desplazamiento, 
              (SELECT  id_caso, MAX(sivel2_sjr_desplazamiento.fechaexpulsion) 
               AS fechaexpulsion FROM public.sivel2_sjr_desplazamiento  GROUP BY 1) 
               AS s WHERE sivel2_sjr_desplazamiento.id_caso=s.id_caso and 
              sivel2_sjr_desplazamiento.fechaexpulsion=s.fechaexpulsion);")


            if (@pDepartamento == "1") 
              que3 << ["departamento_nombre", "Último Departamento Expulsor"]
            end
            if (@pMunicipio== "1") 
              que3 << ["municipio_nombre", "Último Municipio Expulsor"]
            end

            return ["CREATE OR REPLACE MATERIALIZED VIEW #{personas_cons2} AS SELECT #{personas_cons1}.*,
            ubicacion.id_departamento, 
            departamento.nombre AS departamento_nombre, 
            ubicacion.id_municipio, municipio.nombre AS municipio_nombre, 
            ubicacion.id_clase, clase.nombre AS clase_nombre, 
            ultimodesplazamiento.fechaexpulsion FROM
            #{personas_cons1} LEFT JOIN public.ultimodesplazamiento ON
            (#{personas_cons1}.id_caso = ultimodesplazamiento.id_caso)
            LEFT JOIN msip_ubicacion AS ubicacion ON 
              (ultimodesplazamiento.id_expulsion = ubicacion.id) 
            LEFT JOIN msip_departamento AS departamento ON 
              (ubicacion.id_departamento=departamento.id) 
            LEFT JOIN msip_municipio AS municipio ON 
              (ubicacion.id_municipio=municipio.id)
            LEFT JOIN msip_clase AS clase ON 
              (ubicacion.id_clase=clase.id)
            ", que3, tablas3, where3]
          end

          def personas_consulta_final(i, que3, tablas3, where3, qc, gb)
            @coltotales = [i-1, i, i+1]
            que3 << ["", "Contactos"]
            que3 << ["", "Beneficiarios"]
            que3 << ["", "Total"]
            twhere3 = where3 == "" ? "" : "WHERE " + where3
            return "SELECT #{qc}
            SUM(#{personas_cons2}.contacto) AS contacto, 
            SUM(#{personas_cons2}.beneficiario) AS beneficiario,
            SUM(#{personas_cons2}.npersona) AS npersona
            FROM #{tablas3}
            #{twhere3}
            #{gb}"
          end
          
        end # included

      end
    end
  end
end

