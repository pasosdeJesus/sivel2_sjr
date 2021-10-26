module Sivel2Sjr
  class ProgestadoRespuesta < ActiveRecord::Base
    belongs_to :progestado, class_name: "Sivel2Sjr::Progestado", 
      foreign_key: "id_progestado", validate: true
    belongs_to :respuesta, class_name: "Sivel2Sjr::Rrespuesta", 
      foreign_key: "id_respuesta", validate: true
  end
end
