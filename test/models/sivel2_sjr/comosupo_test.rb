require_relative '../../test_helper'

module Sivel2Sjr
  class ComosupoTest < ActiveSupport::TestCase

    PRUEBA_COMOSUPO={
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11"
    }

    test "valido" do
      comosupo = Comosupo.create PRUEBA_COMOSUPO
      assert comosupo.valid?
      comosupo.destroy
    end

    test "no valido" do
      comosupo = Comosupo.new PRUEBA_COMOSUPO
      comosupo.nombre=''
      assert_not comosupo.valid?
      comosupo.destroy
    end

    test "existente" do
      comosupo = Comosupo.where(id: 1).take
      assert_equal comosupo.nombre, "SIN INFORMACIÓN"
    end

  end
end
