require 'pastel'

module SqlQueryAnalyzer
  class QueryPlanPresenter
    def initialize(output:, warnings:, total_cost:, rows_estimate:, actual_time:)
      @output = output
      @warnings = warnings
      @total_cost = total_cost
      @rows_estimate = rows_estimate
      @actual_time = actual_time
      @pastel = Pastel.new
    end

    def display
      puts @pastel.bold("\n🔍 QUERY PLAN:")
      @output.each_with_index do |line, idx|
        puts "  #{@pastel.cyan("#{idx + 1}:")} #{line}"
      end

      puts @pastel.bold("\n📊 Query Metrics:")
      puts "  💰 Total Cost: #{@pastel.green(@total_cost)}" if @total_cost
      puts "  📈 Rows Estimate: #{@pastel.blue(@rows_estimate)}" if @rows_estimate
      puts "  ⏱️  Actual Time: #{@pastel.magenta("#{@actual_time} ms")}" if @actual_time

      if @warnings.any?
        puts @pastel.bold("\n🚩 Warnings and Suggestions:")
        @warnings.each do |warn|
          puts "  #{@pastel.yellow("Line #{warn[:line_number]}:")} #{warn[:line_text]}"
          puts "    👉 #{colorize_by_severity(warn[:suggestion])}"
        end
      else
        puts @pastel.green("\n✅ No immediate problems detected in the query plan.")
      end
    end

    def self.classify_cost(cost)
      return unless cost
      pastel = Pastel.new

      case cost
      when 0..300
        puts pastel.green("\n✅ Query cost is LOW. All good!")
      when 301..1000
        puts pastel.yellow("\n🧐 Query cost is MODERATE. May benefit from optimizations.")
      else
        puts pastel.red.bold("\n🛑 Query cost is HIGH. Recommend tuning immediately!")
      end
    end

    private

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
