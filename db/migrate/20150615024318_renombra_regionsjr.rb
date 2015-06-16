class RenombraRegionsjr < ActiveRecord::Migration
  def change
    rename_column :sivel2_sjr_casosjr, :id_regionsjr, :oficina_id
  end
end
