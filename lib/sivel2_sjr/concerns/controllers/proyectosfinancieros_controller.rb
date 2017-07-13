# encoding: UTF-8

require_dependency 'cor1440_gen/concerns/controllers/proyectosfinancieros_controller'

module Sivel2Sjr
  module Concerns
    module Controllers
      module ProyectosfinancierosController
        extend ActiveSupport::Concern

        included do

          include Cor1440Gen::Concerns::Controllers::ProyectosfinancierosController

          def index(c = nil)
            if c == nil
              c = Cor1440Gen::Proyectofinanciero.all
            end
            if current_usuario.rol != Ability::ROLADMIN &&
              current_usuario.rol != Ability::ROLDIR
              c = c.where('cor1440_gen_proyectofinanciero.id IN 
              (SELECT proyectofinanciero_id 
              FROM sivel2_sjr_oficina_proyectofinanciero 
              WHERE oficina_id=?)', current_usuario.oficina_id)
            end
            super(c)
          end

          def atributos_index
            [ "id", 
              "nombre" ] +
              [ :financiador_ids =>  [] ] +
              [ "fechainicio_localizada",
                "fechacierre_localizada",
                "responsable_id"
            ] +
            [ :oficina_ids =>  [] ] +
            [ :proyecto_ids =>  [] ] +
            [ 
              "compromisos",
              "monto",
              "observaciones"
            ] 
          end

        end # included

      end
    end
  end
end

