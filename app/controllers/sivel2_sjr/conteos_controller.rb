require 'sivel2_sjr/concerns/controllers/conteos_controller'

module Sivel2Sjr
  class ConteosController < ApplicationController

    # autorizacion en cada función
    
    include Sivel2Sjr::Concerns::Controllers::ConteosController

  end
end
