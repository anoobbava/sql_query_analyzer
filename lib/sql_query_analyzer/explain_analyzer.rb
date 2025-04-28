# lib/sql_query_analyzer/explain_analyzer.rb
module SqlQueryAnalyzer
  module ExplainAnalyzer
    def explain_with_suggestions
      explain_output = explain(analyze: true, verbose: true, costs: true, buffers: true, timing: true)

      engine = SqlQueryAnalyzer::SuggestionEngine.new(explain_output, to_sql)
      suggestions = engine.analyze

      puts "\n=== EXPLAIN ANALYZE OUTPUT ===\n"
      puts explain_output
      puts "\n=== SUGGESTIONS ===\n"
      suggestions.each do |suggestion|
        puts "[#{suggestion.severity.to_s.upcase}] #{suggestion.message}"
      end
    rescue => e
      puts "Error analyzing query: #{e.message}"
    end
  end
end

# Monkey patch it in Rails
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.include(SqlQueryAnalyzer::ExplainAnalyzer)
end
