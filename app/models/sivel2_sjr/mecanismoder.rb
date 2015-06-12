# encoding: UTF-8
module Sivel2Sjr
  class Mecanismoder < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :procesosjr, class_name: "Sivel2Sjr::Procesosjr", 
      foreign_key: "id_mecanismoder", validate: true
  	has_many :procesosjr, class_name: "Sivel2Sjr::Procesosjr", 
      foreign_key: "otromecanismo", validate: true
  end
end
