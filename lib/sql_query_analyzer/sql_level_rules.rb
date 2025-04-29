module SqlQueryAnalyzer
  class SqlLevelRules
    def self.evaluate(sql)
      return [] unless sql

      warnings = []

      if sql.match?(/select\s+\*/i)
        warnings << {
          line_number: 'N/A',
          line_text: 'SELECT *',
          suggestion: Suggestion.new(:warning, "🚨 Query uses SELECT *. Specify only needed columns for performance.")
        }
      end

      if sql.match?(/join/i) && !sql.match?(/on/i)
        warnings << {
          line_number: 'N/A',
          line_text: 'JOIN without ON',
          suggestion: Suggestion.new(:critical, "⚡ JOIN without ON detected. May cause massive row combinations (CROSS JOIN).")
        }
      end

      warnings
    end
  end
end
