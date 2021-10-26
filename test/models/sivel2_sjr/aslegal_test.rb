require_relative '../../test_helper'

module Sivel2Sjr
  class AslegaTest < ActiveSupport::TestCase

    PRUEBA_ASLEGAL={
      nombre: "A",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11"
    }

    test "valido" do
      aslegal = Aslegal.create PRUEBA_ASLEGAL
      assert aslegal.valid?
      aslegal.destroy
    end

    test "no valido" do
      aslegal = Aslegal.new PRUEBA_ASLEGAL
      aslegal.nombre = ''
      assert_not aslegal.valid?
      aslegal.destroy
    end

    test "existente" do
      aslegal = Sivel2Sjr::Aslegal.where(id: 0).take
      assert_equal aslegal.nombre, "SIN INFORMACIÓN"
    end

  end
end
