# encoding: UTF-8

require 'sivel2_sjr/concerns/models/maternidad'

class Sivel2Gen::Maternidad < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Maternidad
end

