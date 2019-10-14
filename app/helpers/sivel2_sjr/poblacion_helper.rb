module Sivel2Sjr
  module PoblacionHelper

    # En una actividad (nueva) crea tabla población a partir de la
    # información de víctimas del caso caso_id y empleando como fecha
    # de referencia para el cálculo de edades (anio, mes, dia)
    def crea_poblacion_rangoedadac(actividad_id, caso_id, anio, mes, dia)
      rangoedadsexo = {}
      totsexo = {}
      Sivel2Gen::RangoedadHelper.poblacion_por_rango_sexo(
          caso_id, anio, mes, dia,
          'Cor1440Gen::Rangoedadac', rangoedadsexo, totsexo)
      rangoedadsexo.each do |re_id, gs|
        tf = gs['F'] ? gs['F'] : 0
        tm = gs['M'] ? gs['M'] : 0
        tm += gs['S'] ? gs['S'] : 0
        rea = Cor1440Gen::ActividadRangoedadac.create({
          actividad_id: actividad_id,
          rangoedadac_id: re_id,
          fr: tf,
          mr: tm
        })
        rea.save
      end
    end
    module_function :crea_poblacion_rangoedadac

  end
end
