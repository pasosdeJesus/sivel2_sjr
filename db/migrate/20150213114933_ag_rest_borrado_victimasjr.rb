class AgRestBorradoVictimasjr < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    ALTER TABLE sivel2_sjr_victimasjr
    DROP CONSTRAINT victimasjr_id_victima_fkey,
    ADD CONSTRAINT victimasjr_id_victima_fkey
       FOREIGN KEY (id_victima)
       REFERENCES sivel2_gen_victima(id)
       ON DELETE CASCADE;
    SQL
  end
end
