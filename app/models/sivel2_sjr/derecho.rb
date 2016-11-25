# encoding: UTF-8

require 'sivel2_sjr/concerns/models/derecho'

class Sivel2Sjr::Derecho < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Derecho
end
