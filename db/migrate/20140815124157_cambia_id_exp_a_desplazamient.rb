class CambiaIdExpADesplazamient < ActiveRecord::Migration[4.2]
  def change
    rename_column :desplazamiento, :expulsion, :id_expulsion
    rename_column :desplazamiento, :llegada, :id_llegada
  end
end
