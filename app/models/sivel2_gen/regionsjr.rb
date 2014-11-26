# encoding: UTF-8

require 'sivel2_sjr/concerns/models/regionsjr'

class Sivel2Gen::Regionsjr < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Regionsjr
end

