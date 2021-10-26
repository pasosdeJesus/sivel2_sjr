require 'sivel2_sjr/concerns/models/aslegal'

module Sivel2Sjr
  class Aslegal < ActiveRecord::Base
    include Sivel2Sjr::Concerns::Models::Aslegal
  end
end
