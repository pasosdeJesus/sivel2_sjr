# encoding: UTF-8

module Sivel2Sjr
  class AspsicosocialRespuesta < ActiveRecord::Base
    belongs_to :aspsicosocial, class_name: "Sivel2Sjr::Aspsicosocial", 
      foreign_key: "id_aspsicosocial", validate: true
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "id_respuesta", validate: true
  end
end
