module Sivel2Sjr
  class Aspsicosocial < ActiveRecord::Base
    include Msip::Basica

    has_many :aspsicosocial_respuesta, 
      class_name: "Sivel2Sjr::AspsicosocialRespuesta", 
      foreign_key: "aspsicosocial_id", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :aspsicosocial_respuesta

    validates :nombre, presence: true, allow_blank: false
    validates :fechacreacion, presence: true, allow_blank: false
  end
end
