module Sivel2Sjr
  class OficinaProyectofinanciero < ActiveRecord::Base
    belongs_to :oficina, class_name: 'Msip::Oficina',
      foreign_key: 'oficina_id', optional: false
    belongs_to :proyectofinanciero, 
      class_name: 'Cor1440Gen::Proyectofinanciero', 
      foreign_key: 'proyectofinanciero_id', optional: false
  end
end
