# encoding: UTF-8
module Sivel2Sjr
  class ProgestadoDerecho < ActiveRecord::Base
    belongs_to :progestado, class_name: "Sivel2Sjr::Progestado", 
      foreign_key: "id_progestado", validate: true
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "id_derecho", validate: true
  end
end
