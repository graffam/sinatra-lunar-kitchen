class PsqlCon
  def self.connect
    begin
      active_connection = PG.connect(dbname: 'recipes')
      yield(active_connection)
    ensure
      active_connection.close
    end
  end
end
