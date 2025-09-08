# frozen_string_literal: true

# lib/sql_query_analyzer/explain_analyzer.rb
module SqlQueryAnalyzer
  # Module that adds explain_with_suggestions method to ActiveRecord::Relation
  module ExplainAnalyzer
    def explain_with_suggestions(run: false)
      unless is_a?(ActiveRecord::Relation)
        puts '⚠️ Not an ActiveRecord Relation. Skipping explain_with_suggestions.'
        return nil
      end

      raw_sql = to_sql

      explain_output = SqlQueryAnalyzer::Execute.explain_sql(raw_sql, run)
      engine = SqlQueryAnalyzer::SuggestionEngine.new(explain_output, raw_sql)
      engine.analyze
    rescue StandardError => e
      puts "Error analyzing query: #{e.message}"
      nil
    end
  end
end

# Monkey patch it in Rails
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.include(SqlQueryAnalyzer::ExplainAnalyzer)
end
