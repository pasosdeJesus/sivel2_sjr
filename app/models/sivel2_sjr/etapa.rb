# encoding: UTF-8
module Sivel2Sjr
  class Etapa < ActiveRecord::Base
    include Sivel2Gen::Basica

    has_many :proceso, class_name: "Sivel2Sjr::Proceso",
      foreign_key: "id_etapa", validate: true
    belongs_to :tproceso, class_name: "Sivel2Sjr::Troceso", 
      foreign_key: "id_tproceso", validate: true
  end
end
