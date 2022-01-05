module Sivel2Sjr
  class AyudasjrRespuesta < ActiveRecord::Base
    belongs_to :ayudasjr, class_name: "Sivel2Sjr::Ayudasjr",  validate: true,
      foreign_key: "id_ayudasjr", optional: false
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", validate: true,
      foreign_key: "id_respuesta", optional: false
  end
end
