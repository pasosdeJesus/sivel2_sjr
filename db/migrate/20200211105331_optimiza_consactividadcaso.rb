class OptimizaConsactividadcaso < ActiveRecord::Migration[6.0]

  def up
    execute <<-SQL
      CREATE INDEX ON public.sivel2_sjr_actividad_casosjr
        (actividad_id);
      CREATE INDEX ON public.sivel2_sjr_actividad_casosjr
        (casosjr_id);
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX public.sivel2_sjr_actividad_casosjr_casosjr_id_idx;
      DROP INDEX public.sivel2_sjr_actividad_casosjr_actividad_id_idx;
    SQL
  end

end
