class AspsicosocialASivel2Sjr < ActiveRecord::Migration[5.2]
  def up
    if table_exists? :aspsicosocial
      rename_table :aspsicosocial, :sivel2_sjr_aspsicosocial
      rename_table :aspsicosocial_respuesta, :sivel2_sjr_aspsicosocial_respuesta
      execute <<-SQL
        ALTER SEQUENCE IF EXISTS aspsicosocial_seq RENAME TO sivel2_sjr_aspsicosocial_id_seq;
      SQL
      create_table :sivel2_sjr_aspsicosocial do |t|
        t.string :nombre, limit: 100, null: false
        t.string :observaciones, limit: 5000
        t.date :fechacreacion, null: false
        t.date :fechadeshabilitacion

        t.timestamps
      end
      create_join_table :aspsicosocial, :respuesta, {
        table_name: 'sivel2_sjr_aspsicosocial_respuesta'
      }
      rename_column :sivel2_sjr_aspsicosocial_respuesta, :aspsicosocial_id, :id_aspsicosocial
      rename_column :sivel2_sjr_aspsicosocial_respuesta, :respuesta_id, :id_respuesta
      add_foreign_key :sivel2_sjr_aspsicosocial_respuesta, 
        :sivel2_sjr_aspsicosocial, column: :id_aspsicosocial
      add_foreign_key :sivel2_sjr_aspsicosocial_respuesta, 
        :sivel2_sjr_respuesta,  column: :id_respuesta
      execute <<-SQL
        INSERT INTO public.sivel2_sjr_aspsicosocial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2014-02-14', NULL, '2014-02-14', '2014-02-14', NULL);
        INSERT INTO public.sivel2_sjr_aspsicosocial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'ATENCIÓN PSICOLÓGICA (INDIVIDUAL, GRUPAL O FAMILIAR)', '2014-02-14', NULL, '2014-02-14', '2014-02-14', NULL);
        INSERT INTO public.sivel2_sjr_aspsicosocial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'SEGUIMIENTO A - VISITAS', '2014-02-14', NULL, '2014-02-14', '2014-02-14', NULL);
        INSERT INTO public.sivel2_sjr_aspsicosocial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'PARTICIPACIÓN', '2014-02-14', NULL, '2014-02-14', '2014-02-14', NULL);
        INSERT INTO public.sivel2_sjr_aspsicosocial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'ACOMPAÑAMIENTO ESPIRITUAL, FORTALECIMIENTO TEJIDO SOCIAL', '2014-02-14', NULL, '2014-02-14', '2014-02-14', NULL);
        INSERT INTO public.sivel2_sjr_aspsicosocial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'REDES DE APOYO', '2014-02-14', NULL, '2014-02-14', '2014-02-14', NULL);
        INSERT INTO public.sivel2_sjr_aspsicosocial (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (102, 'PRIMEROS AUXILIOS PSICOLOGICOS', '2014-07-01', NULL, '2014-07-01 15:37:35.991268', '2014-07-01 15:37:35.991268', NULL);
      SQL
    end
  end
  def down
      rename_table :sivel2_sjr_aspsicosocial, :aspsicosocial
      rename_table :sivel2_sjr_aspsicosocial_respuesta, :aspsicosocial_respuesta
  end
end
