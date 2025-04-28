# lib/sql_query_analyzer/suggestion_engine.rb
module SqlQueryAnalyzer
  class Suggestion
    attr_reader :severity, :message

    def initialize(severity, message)
      @severity = severity
      @message = message
    end
  end

  class SuggestionEngine
    def initialize(explain_output, sql = nil)
      @explain_output = explain_output
      @sql = sql
    end

    def analyze
      suggestions = []

      # Rule 1: Sequential Scan
      if @explain_output.match?(/Seq Scan/i)
        suggestions << Suggestion.new(:critical, "⚡ Sequential Scan detected. Consider adding indexes to avoid full table scans.")
      end

      # Rule 2: SELECT *
      if @sql&.match?(/select\s+\*/i)
        suggestions << Suggestion.new(:warning, "🚨 Query uses SELECT *. Selecting only needed columns is more efficient.")
      end

      # Rule 3: Sort operation
      if @explain_output.match?(/Sort/i)
        suggestions << Suggestion.new(:info, "📈 Sort detected. Consider adding an index to support ORDER BY.")
      end

      # Rule 4: Missing JOIN conditions
      if @sql&.match?(/join/i) && !@sql.match?(/on/i)
        suggestions << Suggestion.new(:critical, "⚡ JOIN without ON detected. May cause massive row combinations (CROSS JOIN).")
      end

      # Rule 5: High Rows estimation
      if @explain_output.match?(/rows=(\d+)/)
        rows = @explain_output.match(/rows=(\d+)/)[1].to_i
        if rows > 100_000
          suggestions << Suggestion.new(:critical, "🔥 High number of rows (#{rows}). Consider using WHERE conditions or LIMIT.")
        end
      end

      suggestions
    end
  end
end
