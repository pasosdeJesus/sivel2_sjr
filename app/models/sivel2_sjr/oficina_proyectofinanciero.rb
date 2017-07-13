# encoding: UTF-8

module Sivel2Sjr
  class OficinaProyectofinanciero < ActiveRecord::Base
    belongs_to :oficina, class_name: 'Sip::Oficina',
      foreign_key: 'oficina_id'
    belongs_to :proyectofinanciero, 
      class_name: 'Cor1440Gen::Proyectofinanciero', 
      foreign_key: 'proyectofinanciero_id'
  end
end
