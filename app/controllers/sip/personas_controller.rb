# encoding: UTF-8
require 'sivel2_sjr/concerns/controllers/personas_controller'

module Sip
  class PersonasController < Heb412Gen::ModelosController
    include Sivel2Sjr::Concerns::Controllers::PersonasController

    load_and_authorize_resource class: Sip::Persona

  end
end
