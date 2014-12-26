# encoding: UTF-8
module Sivel2Sjr
  class AyudasjrDerecho < ActiveRecord::Base
    belongs_to :ayudasjr, class_name: "Sivel2Sjr::Ayudasjr", 
      foreign_key: "ayudasjr_id", validate: true
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", validate: true
  end
end
