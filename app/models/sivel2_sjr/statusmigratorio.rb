# encoding: UTF-8
module Sivel2Sjr
  class Statusmigratorio < ActiveRecord::Base
    include Sivel2Gen::Basica
  
  	has_many :casosjr, class_name: "Sivel2Sjr::Casosjr", 
      foreign_key: "id_statusmigratorio", validate: true
  end
end
