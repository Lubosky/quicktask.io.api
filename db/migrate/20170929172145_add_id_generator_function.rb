class AddIdGeneratorFunction < ActiveRecord::Migration[5.1]
  def self.up
    execute <<-SQL
      CREATE SEQUENCE table_id_sequence
        INCREMENT 1
        START 1
        CACHE 1;

      CREATE OR REPLACE FUNCTION generate_id(OUT result bigint) AS $$
        DECLARE
          epoch bigint := 1514764800000;
          sequence_id bigint;
          milliseconds_now bigint;
          shard_id int := 0;
        BEGIN
          SELECT nextval(\'table_id_sequence\') % 1024 INTO sequence_id;
          SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO milliseconds_now;
          result := (milliseconds_now - epoch) << 23;
          result := result | (shard_id << 10);
          result := result | (sequence_id);
        END;
        $$ LANGUAGE PLPGSQL;
    SQL
  end

  def self.down
    execute <<-SQL
      DROP FUNCTION generate_id(OUT result bigint);
    SQL

    execute <<-SQL
      DROP SEQUENCE table_id_sequence;
    SQL
  end
end
