# lib/sql_query_analyzer/explain_analyzer.rb
module SqlQueryAnalyzer
  module ExplainAnalyzer
    def explain_with_suggestions

      unless self.is_a?(ActiveRecord::Relation)
        puts "⚠️ Not an ActiveRecord Relation. Skipping explain_with_suggestions."
        return
      end

      raw_sql = self.to_sql

      explain_output = SqlQueryAnalyzer::Execute.explain_sql(raw_sql)
      engine = SqlQueryAnalyzer::SuggestionEngine.new(explain_output, raw_sql)
      suggestions = engine.analyze

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
