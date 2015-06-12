# encoding: UTF-8
module Sivel2Sjr
  class Proteccion < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :casosjr, class_name: "Sivel2Sjr::Casosjr", 
      foreign_key: "id_proteccion", validate: true
  end
end
