module SqlQueryAnalyzer
  class Explainer
    def self.explain_sql(sql)
      explain_sql = <<~SQL
        EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS, TIMING)
        #{sql}
      SQL
      result = ActiveRecord::Base.connection.execute(explain_sql)
      result.values.flatten.join("\n")
    end
  end
end
