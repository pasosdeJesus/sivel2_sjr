# encoding: UTF-8

module Sivel2Sjr
  class Declaroante < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "id_declaroante", validate: true
  end
end
