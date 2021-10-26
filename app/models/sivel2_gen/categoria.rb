require 'sivel2_sjr/concerns/models/categoria'

class Sivel2Gen::Categoria < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Categoria
end

