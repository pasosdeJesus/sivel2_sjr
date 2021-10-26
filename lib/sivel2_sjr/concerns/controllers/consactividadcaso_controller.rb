module Sivel2Sjr
  module Concerns
    module Controllers
      module ConsactividadcasoController
        extend ActiveSupport::Concern


        included do

          def clase
            'Sivel2Sjr::Consactividadcaso'
          end

          def atributos_index
            [:caso_id,
             :actividad_id,
             :actividad_fecha,
             :actividad_proyectofinanciero,
             :persona_nombres,
             :persona_apellidos,
             :tipos_actividad
            ]
          end
          
          def index_reordenar(c)
            aapf = Cor1440Gen::ActividadActividadpf.where(actividad_id: 
                                                         c.pluck(:actividad_id))
            apf= Cor1440Gen::Actividadpf.where(id: aapf.pluck(:actividadpf_id))
      

            @actipos = Cor1440Gen::Actividadtipo.where(
              id: apf.pluck(:actividadtipo_id)).pluck(:id, :nombre)
            c.reorder([:caso_id, :actividad_id])
          end 
            
          def vistas_manejadas
            ['Consactividadcaso']
          end

          # Genera conteo por caso/beneficiario y tipo de actividad de convenio
          # #caso #act fechaact nom ap id gen edadfact rangoedad_fact etnia tipoac1 tipoac2 tipoac3 tipoac4 ... oficina asesoract 
          #                 EDADES HOMBRES            EDADES MUJERES                    
          #                                 0-5 6-12  13-17 18-26 27-59 +60 0-5 6-12  13-17 18-26 27-59 +60         
          def index
            Sivel2Sjr::Consactividadcaso.refresca_consulta

            index_sip(Sivel2Sjr::Consactividadcaso.all)
          end

        end #included


        class_methods do
          def valor_campo_compuesto(registro, campo)
            puts "registro=#{registro}"
            puts "campo=#{campo}"
            p = campo.split('.')
            if Mr519Gen::Formulario.where(nombreinterno: p[0]).count == 0
              return "No se encontró formulario con nombreinterno #{p[0]}"
            end
            f = Mr519Gen::Formulario.where(nombreinterno: p[0]).take

            rf = registro.actividad.respuestafor.where(
              formulario_id: f.id)
            if rf.count == 0
              return "" #No se encontró respuesta a formulario en cactividad
            elsif rf.count > 1
              return "Hay #{rf.count} respuestas al formulario #{f.id}"
            end
            rf = rf.take

            if p[1] == 'fecha_ultimaedicion'
              return rf.fechacambio
            end

            if f.campo.where(nombreinterno: p[1]).count == 0
              return "En formulario #{f.id} no se encontró campo con nombre interno #{p[2]}"
            end
            campo = f.campo.where(nombreinterno: p[1]).take
            op = []
            ope = nil
            if campo.tipo == 
                Mr519Gen::ApplicationHelper::SELECCIONMULTIPLE
              op = campo.opcioncs
              if p.count > 2 # Solicitud tiene opcion
                if op.where(valor: p[2]).count == 0
                  return "En formulario #{f.id}, el campo con nombre interno #{p[1]} no tiene una opción con valor #{p[2]}"
                elsif op.where(valor: p[2]).count > 1
                  return "En formulario #{f.id}, el campo con nombre interno #{p[1]} tiene más de una opción con valor #{p[2]}"
                end
                ope = op.where(valor: p[2]).take
              end
            end
            if rf.valorcampo.where(campo_id: campo.id).count == 0
              return "En respuesta a formulario #{rf.id} no se encontró valor para el campo #{campo.id}"
            end

            vc = rf.valorcampo.where(campo_id: campo.id).take
            if !ope.nil?
              return vc.valorjson.include?(ope.id.to_s) ? 1 : 0
            end
            if campo.tipo == Mr519Gen::ApplicationHelper::SELECCIONMULTIPLE
              cop = vc.valorjson.select{|i| i != ''}.map {|idop|
                ope = Mr519Gen::Opcioncs.where(id: idop.to_i)
                ope.count == 0  ?  "No hay opcion con id #{idop}" :
                  ope.take.nombre
              }
              return cop.join(". ")
            end

            vc.presenta_valor(false)
          end


        end


      end
    end
  end
end

