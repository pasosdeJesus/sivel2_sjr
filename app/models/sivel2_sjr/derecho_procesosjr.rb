# encoding: UTF-8
module Sivel2Sjr
  class DerechoProcesosjr < ActiveRecord::Base
  	belongs_to :procesosjr, class_name: "Sivel2Sjr::Procesosjr", 
      foreign_key: "id_proceso", validate: true
  	belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "id_derecho", validate: true
  end
end
