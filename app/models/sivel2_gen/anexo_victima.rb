# encoding: UTF-8

require 'sivel2_sjr/concerns/models/anexo_victima'

module Sivel2Gen
  class AnexoVictima < ActiveRecord::Base
    include Sivel2Sjr::Concerns::Models::AnexoVictima
  end
end
