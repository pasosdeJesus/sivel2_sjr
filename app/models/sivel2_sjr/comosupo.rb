# encoding: UTF-8
module Sivel2Sjr
  class Comosupo < ActiveRecord::Base
    include Sivel2Gen::Basica
  
  	has_many :casosjr, class_name: "Sivel2Sjr::Casosjr"
  
    validates :nombre, presence: true, allow_blank: false
    validates :fechacreacion, presence: true, allow_blank: false
  end
end
