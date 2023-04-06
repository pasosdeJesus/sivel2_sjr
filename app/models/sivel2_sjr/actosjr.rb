module Sivel2Sjr
  class Actosjr < ActiveRecord::Base

    include Msip::Modelo

    belongs_to :acto, class_name: "Sivel2Gen::Acto", 
      foreign_key: "acto_id", inverse_of: :actosjr,
      dependent: :delete, optional: false
    belongs_to :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento",
      optional: true
  end
end
