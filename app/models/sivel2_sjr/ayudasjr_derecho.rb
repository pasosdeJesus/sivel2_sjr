# encoding: UTF-8
module Sivel2Sjr
  class AyudasjrDerecho < ActiveRecord::Base
    belongs_to :ayudasjr, class_name: "Sivel2Sjr::Ayudasjr", 
      foreign_key: "id_ayudasjr", validate: true
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "id_derecho", validate: true
  end
end
