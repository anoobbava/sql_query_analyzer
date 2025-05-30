module SqlQueryAnalyzer
  class Execute
    def self.explain_sql(raw_sql, run)
      query_with_options = run ? "EXPLAIN ANALYZE #{raw_sql}" : "EXPLAIN #{raw_sql}"
      ActiveRecord::Base.connection.execute(query_with_options)
    end
  end
end
