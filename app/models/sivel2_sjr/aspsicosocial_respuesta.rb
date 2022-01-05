module Sivel2Sjr
  class AspsicosocialRespuesta < ActiveRecord::Base
    belongs_to :aspsicosocial, class_name: "Sivel2Sjr::Aspsicosocial", 
      foreign_key: "id_aspsicosocial", validate: true, optional: false
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "id_respuesta", validate: true, optional: false
  end
end
