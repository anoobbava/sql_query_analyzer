# frozen_string_literal: true

require 'pastel'

module SqlQueryAnalyzer
  class QueryPlanPresenter
    def initialize(output:, warnings:, total_cost:, rows_estimate:, actual_time:, output_stream: $stdout)
      @output = output
      @warnings = warnings
      @total_cost = total_cost
      @rows_estimate = rows_estimate
      @actual_time = actual_time
      @pastel = Pastel.new
      @output_stream = output_stream
    end

    def display
      display_query_plan
      display_metrics
      display_warnings_or_success
    end

    def self.classify_cost(cost, output_stream: $stdout)
      return unless cost

      pastel = Pastel.new

      case cost
      when 0..300
        output_stream.puts pastel.green("\n✅ Query cost is LOW. All good!")
      when 301..1000
        output_stream.puts pastel.yellow("\n🧐 Query cost is MODERATE. May benefit from optimizations.")
      else
        output_stream.puts pastel.red.bold("\n🛑 Query cost is HIGH. Recommend tuning immediately!")
      end
    end

    private

    def display_query_plan
      @output_stream.puts @pastel.bold("\n🔍 QUERY PLAN:")
      @output.each_with_index do |line, idx|
        @output_stream.puts "  #{@pastel.cyan("#{idx + 1}:")} #{line}"
      end
    end

    def display_metrics
      @output_stream.puts @pastel.bold("\n📊 Query Metrics:")
      @output_stream.puts "  💰 Total Cost: #{@pastel.green(@total_cost)}" if @total_cost
      @output_stream.puts "  📈 Rows Estimate: #{@pastel.blue(@rows_estimate)}" if @rows_estimate
      @output_stream.puts "  ⏱️  Actual Time: #{@pastel.magenta("#{@actual_time} ms")}" if @actual_time
    end

    def display_warnings_or_success
      if @warnings.any?
        @output_stream.puts @pastel.bold("\n🚩 Warnings and Suggestions:")
        @warnings.each do |warn|
          @output_stream.puts "  #{@pastel.yellow("Line #{warn[:line_number]}:")} #{warn[:line_text]}"
          @output_stream.puts "    👉 #{colorize_by_severity(warn[:suggestion])}"
        end
      else
        @output_stream.puts @pastel.green("\n✅ No immediate problems detected in the query plan.")
      end
    end

    def colorize_by_severity(suggestion)
      case suggestion.severity
      when :critical
        @pastel.red.bold(suggestion.to_s)
      when :warning
        @pastel.yellow.bold(suggestion.to_s)
      when :info
        @pastel.cyan(suggestion.to_s)
      else
        suggestion.to_s
      end
    end
  end
end
