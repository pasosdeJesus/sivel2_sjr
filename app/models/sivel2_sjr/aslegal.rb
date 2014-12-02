# encoding: UTF-8
module Sivel2Sjr
  class Aslegal < ActiveRecord::Base
    include Sivel2Gen::Basica
  
    has_many :aslegal_respuesta, class_name: "Sivel2Sjr::AslegalRespuesta", 
      foreign_key: "id_aslegal", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta",
      :through => :aslegal_respuesta
  end
end
