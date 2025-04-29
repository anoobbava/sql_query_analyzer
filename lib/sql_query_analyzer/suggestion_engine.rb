require_relative 'suggestion_rules'
require_relative 'query_plan_presenter'
require_relative 'sql_level_rules'

module SqlQueryAnalyzer
  class Suggestion
    attr_reader :severity, :message

    def initialize(severity, message)
      @severity = severity
      @message = message
    end

    def to_s
      "[#{severity.to_s.upcase}] #{message}"
    end
  end

  class SuggestionEngine
    def initialize(explain_output, sql = nil)
      @explain_output = explain_output
      @sql = sql
    end

    def analyze
      output = []
      warnings = []
      total_cost, rows_estimate, actual_time = nil

      @explain_output.each_with_index do |row, idx|
        line = row["QUERY PLAN"]
        output << line

        if line =~ /cost=\d+\.\d+\.\.(\d+\.\d+) rows=(\d+)/
          total_cost = $1.to_f
          rows_estimate = $2.to_i
        end

        actual_time ||= $1.to_f if line =~ /actual time=(\d+\.\d+)/

        SuggestionRules.all.each do |rule|
          if rule[:matcher].call(line)

            suggestion = Suggestion.new(rule[:severity], rule[:message])
            if rule[:message].include?("Sequential Scan")
              dynamic_msg = SequentialScanAdvisor.new(line).enhanced_message
              suggestion = Suggestion.new(rule[:severity], dynamic_msg) if dynamic_msg
            end

            warnings << {
              line_number: idx + 1,
              line_text: line,
              suggestion: suggestion
            }
          end
        end
      end

      warnings.concat(SqlLevelRules.evaluate(@sql))

      presenter = QueryPlanPresenter.new(
        output: output,
        warnings: warnings,
        total_cost: total_cost,
        rows_estimate: rows_estimate,
        actual_time: actual_time
      )

      presenter.display
      QueryPlanPresenter.classify_cost(total_cost)
    end
  end
end
