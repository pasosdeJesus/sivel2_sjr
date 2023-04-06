module Sivel2Sjr
  class AspsicosocialRespuesta < ActiveRecord::Base
    belongs_to :aspsicosocial, class_name: "Sivel2Sjr::Aspsicosocial", 
      foreign_key: "aspsicosocial_id", validate: true, optional: false
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "respuesta_id", validate: true, optional: false
  end
end
