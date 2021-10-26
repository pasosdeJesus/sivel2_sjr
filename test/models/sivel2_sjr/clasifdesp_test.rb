require_relative '../../test_helper'

module Sivel2Sjr
  class ClasifdespTest < ActiveSupport::TestCase

    PRUEBA_CLASIFDESP={
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11"
    }

    test "valido" do
      clasifdesp = Clasifdesp.create PRUEBA_CLASIFDESP
      assert clasifdesp.valid?
      clasifdesp.destroy
    end

    test "no valido" do
      clasifdesp = Clasifdesp.new PRUEBA_CLASIFDESP 
      clasifdesp.nombre=''
      assert_not clasifdesp.valid?
      clasifdesp.destroy
    end

    test "existente" do
      clasifdesp = Sivel2Sjr::Clasifdesp.where(id: 0).take
      assert_equal clasifdesp.nombre, "SIN INFORMACIÓN"
    end

  end
end
