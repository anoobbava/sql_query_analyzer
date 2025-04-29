module SqlQueryAnalyzer
  class Execute
    def self.explain_sql(raw_sql)
      ActiveRecord::Base.connection.execute("EXPLAIN ANALYZE #{raw_sql}")
    end
  end
end
