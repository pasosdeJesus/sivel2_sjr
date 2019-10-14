class CompletaPoblacionRespconv < ActiveRecord::Migration[6.0]
  def change
    Cor1440Gen::Actividad.where("nombre LIKE 'Respuesta al caso %'").
      each do |a|
      if a.casosjr_ids.length > 0
        Sivel2Sjr::PoblacionHelper.crea_poblacion_rangoedadac(
          a.id, a.casosjr_ids[0], a.fecha.year, a.fecha.month, a.fecha.day)
      end
    end
  end

  def down
    execute <<-SQL
      DELETE FROM cor1440_gen_actividadrangoedadac WHERE
        actividad_id IN (SELECT id FROM cor1440_gen_actividad
          WHERE nombre LIKE 'Respuesta al caso%');
    SQL
  end
end
