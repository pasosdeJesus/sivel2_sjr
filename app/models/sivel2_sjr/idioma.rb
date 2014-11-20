# encoding: UTF-8
module Sivel2Sjr
  class Idioma < ActiveRecord::Base
    include Sivel2Gen::Basica
  
  	has_many :casosjr, class_name: "Sivel2Sjr::Casosjr", 
      foreign_key: "id_idioma", validate: true
  
    validates :nombre, presence: true, allow_blank: false
    validates :fechacreacion, presence: true, allow_blank: false
  end
end
