# encoding: UTF-8
module Sivel2Sjr
  class MotivosjrDerecho < ActiveRecord::Base
    belongs_to :motivosjr, class_name: "Sivel2Sjr::Motivosjr", 
      foreign_key: "id_motivosjr", validate: true
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "id_derecho", validate: true
  end
end
