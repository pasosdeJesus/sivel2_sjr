# encoding: UTF-8
module Sivel2Sjr
  class AyudaestadoDerecho < ActiveRecord::Base
    belongs_to :ayudaestado, class_name: "Sivel2Sjr::Ayudaestado", 
      foreign_key: "id_ayudaestado", validate: true
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "id_derecho", validate: true
  end
end
