require 'sivel2_sjr/concerns/controllers/inclusiones_controller'

module Sivel2Sjr
  module Admin
    class InclusionesController < Msip::Admin::BasicasController
      before_action :set_oficina, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Inclusion

      include Sivel2Sjr::Concerns::Controllers::InclusionesController

    end
  end
end
