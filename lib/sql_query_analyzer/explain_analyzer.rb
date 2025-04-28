# lib/sql_query_analyzer/explain_analyzer.rb
module SqlQueryAnalyzer
  module ExplainAnalyzer
    def explain_with_suggestions
      # when Rails 7.1 is there ,we can use the native options. but the still older version does not
      # support parameters
      # explain_output = explain(analyze: true, verbose: true, costs: true, buffers: true, timing: true)
      explain_output = SqlQueryAnalyzer::Explainer.explain_sql(to_sql)
      engine = SqlQueryAnalyzer::SuggestionEngine.new(explain_output, to_sql)
      suggestions = engine.analyze

      puts "\n=== EXPLAIN ANALYZE OUTPUT ===\n"
      puts explain_output
      puts "\n=== SUGGESTIONS ===\n"
      suggestions.each do |suggestion|
        puts suggestion
      end
      nil
    rescue => e
      puts "Error analyzing query: #{e.message}"
    end
  end
end

# Monkey patch it in Rails
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.include(SqlQueryAnalyzer::ExplainAnalyzer)
end
