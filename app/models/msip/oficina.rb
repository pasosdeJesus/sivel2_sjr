require 'sivel2_sjr/concerns/models/oficina'

class Msip::Oficina < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Oficina
end

