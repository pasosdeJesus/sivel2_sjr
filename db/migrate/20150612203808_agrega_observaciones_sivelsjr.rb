class AgregaObservacionesSivelsjr < ActiveRecord::Migration
  def change
    add_column :sivel2_sjr_acreditacion, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_aslegal, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_ayudaestado, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_ayudasjr, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_clasifdesp, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_declaroante, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_derecho, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_idioma, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_inclusion, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_modalidadtierra, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_motivosjr, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_personadesea, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_progestado, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_proteccion, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_rolfamilia, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_statusmigratorio, :observaciones, :string, limit: 5000
    add_column :sivel2_sjr_tipodesp, :observaciones, :string, limit: 5000
  end
end
