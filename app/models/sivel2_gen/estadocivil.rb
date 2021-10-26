require 'sivel2_sjr/concerns/models/estadocivil'

class Sivel2Gen::Estadocivil < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Estadocivil
end

