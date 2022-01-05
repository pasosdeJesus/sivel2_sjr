module Sivel2Sjr
  class Actosjr < ActiveRecord::Base
    belongs_to :acto, class_name: "Sivel2Gen::Acto", 
      foreign_key: "id_acto", inverse_of: :actosjr,
      dependent: :delete, optional: false
    belongs_to :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento",
      optional: true
  end
end
