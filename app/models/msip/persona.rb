require 'sivel2_sjr/concerns/models/persona'

class Msip::Persona < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Persona
end

