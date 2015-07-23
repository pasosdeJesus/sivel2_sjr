# encoding: UTF-8

require 'sivel2_sjr/concerns/models/statusmigratorio.rb'

module Sivel2Sjr
  class Statusmigratorio < ActiveRecord::Base
    include Sivel2Sjr::Concerns::Models::Statusmigratorio 
  end
end
