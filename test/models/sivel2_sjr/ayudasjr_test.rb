require_relative '../../test_helper'

module Sivel2Sjr
  class AyudasjrTest < ActiveSupport::TestCase

    PRUEBA_AYUDASJR={
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11"
    }


    test "valido" do
      ayudasjr = Ayudasjr.create PRUEBA_AYUDASJR
      assert ayudasjr.valid?
      ayudasjr.destroy
    end

    test "no valido" do
      ayudasjr = Ayudasjr.new PRUEBA_AYUDASJR
      ayudasjr.nombre=''
      assert_not ayudasjr.valid?
      ayudasjr.destroy
    end

    test "existente" do
      ayudasjr = Ayudasjr.where(id: 0).take
      assert_equal ayudasjr.nombre, "SIN INFORMACIÓN"
    end

  end
end
