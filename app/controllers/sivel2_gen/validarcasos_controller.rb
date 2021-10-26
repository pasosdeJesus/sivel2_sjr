require 'sivel2_sjr/concerns/controllers/validarcasos_controller'

module Sivel2Gen
  class ValidarcasosController < ApplicationController


    load_and_authorize_resource class: Sivel2Gen::Caso
    include Sivel2Sjr::Concerns::Controllers::ValidarcasosController

  end
end
