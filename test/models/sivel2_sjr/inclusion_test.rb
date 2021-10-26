require_relative '../../test_helper'

module Sivel2Sjr
  class InclusionTest < ActiveSupport::TestCase

    PRUEBA_INCLUSION={
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11"
    }

    test "valido" do
      inclusion = Inclusion.create PRUEBA_INCLUSION
      assert inclusion.valid?
     inclusion.destroy
    end

    test "no valido" do
      inclusion = Inclusion.create PRUEBA_INCLUSION 
      inclusion.nombre=''
      assert_not inclusion.valid?
      inclusion.destroy
    end

    test "existente" do
      inclusion = Sivel2Sjr::Inclusion.where(id: 0).take
      assert_equal inclusion.nombre, "SIN INFORMACIÓN"
    end

  end
end
