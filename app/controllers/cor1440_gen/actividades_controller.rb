# encoding: UTF-8

require_dependency 'cor1440_gen/concerns/controllers/actividades_controller'

class Cor1440Gen::ActividadesController < ApplicationController

  # Funcion por sobrecargar para filtrar por otros parámetros personalizados
  def self.filtramas(par, ac, current_usuario)
    return ac
  end

  include Cor1440Gen::Concerns::Controllers::ActividadesController

  Cor1440Gen.actividadg1 = "Mujeres empleadas SJR"
  Cor1440Gen.actividadg3 = "Hombres empleados SJR"
end
