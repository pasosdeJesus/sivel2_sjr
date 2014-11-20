# encoding: UTF-8
module Sivel2Sjr
  class Clasifdesp < ActiveRecord::Base
    include Sivel2Gen::Basica
  
  	has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "id_clasifdesp", validate: true
  end
end
