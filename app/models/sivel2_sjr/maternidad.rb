# encoding: UTF-8
module Sivel2Sjr
  class Maternidad < ActiveRecord::Base
    include Sivel2Gen::Basica
  
  	has_many :victimasjr, class_name: "Sivel2Sjr::Victimasjr", 
      foreign_key: "id_maternidad", validate: true
    
    validates :nombre, presence: true, allow_blank: false
    validates :fechacreacion, presence: true, allow_blank: false
  end
end
