require  'sivel2_sjr/concerns/controllers/aslegales_controller'

module Sivel2Sjr
  module Admin
    class AslegalesController < Sip::Admin::BasicasController

      before_action :set_aslegal, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Aslegal

      include Sivel2Sjr::Concerns::Controllers::AslegalesController

    end
  end
end
