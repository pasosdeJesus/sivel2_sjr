# encoding: UTF-8
module Sivel2Sjr
  class Instanciader < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :procesosjr, class_name: "Sivel2Sjr::Procesosjr", 
      foreign_key: "id_instanciader", validate: true
  	has_many :procesosjr, class_name: "Sivel2Sjr::Procesosjr", 
      foreign_key: "otrainstancia", validate: true
  end
end
