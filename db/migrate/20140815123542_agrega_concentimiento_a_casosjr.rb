class AgregaConcentimientoACasosjr < ActiveRecord::Migration[4.2]
  def change
    add_column :casosjr, :concentimientosjr, :bool
    add_column :casosjr, :concentimientobd, :bool
  end
end
