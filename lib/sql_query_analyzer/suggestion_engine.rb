require_relative 'suggestion_rules'
require_relative 'query_plan_presenter'
require_relative 'sql_level_rules'
require_relative 'sequential_scan_advisor'

module SqlQueryAnalyzer
  class Suggestion
    attr_reader :severity, :message

    def initialize(severity, message)
      @severity = severity
      @message  = message
    end

    def to_s
      "[#{severity.to_s.upcase}] #{message}"
    end
  end

  class SuggestionEngine
    def initialize(explain_output, sql = nil)
      @explain_output = explain_output
      @sql            = sql
    end

    def analyze
      warnings       = []
      total_cost     = nil
      rows_estimate  = nil
      actual_time    = nil

      # Build the full plan text (all lines) so advisors can see Filters, etc.
      full_plan = @explain_output.map { |row| row["QUERY PLAN"] }.join("\n")

      @explain_output.each_with_index do |row, idx|
        line = row["QUERY PLAN"]

        # Capture cost & estimates
        if line =~ /cost=\d+\.\d+\.\.(\d+\.\d+) rows=(\d+)/
          total_cost    = $1.to_f
          rows_estimate = $2.to_i
        end
        actual_time ||= $1.to_f if line =~ /actual time=(\d+\.\d+)/

        SuggestionRules.all.each do |rule|
          next unless rule[:matcher].call(line)

          message = rule[:message]
          if rule[:message].include?("Sequential Scan")
            dynamic = SequentialScanAdvisor.new(full_plan).enhanced_message
            message = dynamic unless dynamic.nil?
          end

          warnings << {
            line_number: idx + 1,
            line_text:   line,
            suggestion:  Suggestion.new(rule[:severity], message)
          }
        end
      end

      warnings.concat(SqlLevelRules.evaluate(@sql))

      presenter = QueryPlanPresenter.new(
        output:        @explain_output.map { |r| r["QUERY PLAN"] },
        warnings:      warnings,
        total_cost:    total_cost,
        rows_estimate: rows_estimate,
        actual_time:   actual_time
      )

      presenter.display
      QueryPlanPresenter.classify_cost(total_cost)
      warnings
    end
  end
end
