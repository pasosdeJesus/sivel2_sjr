# encoding: UTF-8

require 'sivel2_sjr/concerns/models/persona'

class Sivel2Gen::Persona < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Persona
end

