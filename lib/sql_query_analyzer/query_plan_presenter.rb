module SqlQueryAnalyzer
  class QueryPlanPresenter
    def initialize(output:, warnings:, total_cost:, rows_estimate:, actual_time:)
      @output = output
      @warnings = warnings
      @total_cost = total_cost
      @rows_estimate = rows_estimate
      @actual_time = actual_time
    end

    def display
      puts "\n🔍 QUERY PLAN:"
      @output.each_with_index { |line, idx| puts "  #{idx + 1}: #{line}" }

      puts "\n💰 Total Cost: #{@total_cost}" if @total_cost
      puts "📈 Rows Estimate: #{@rows_estimate}" if @rows_estimate
      puts "⏱️  Actual Time: #{@actual_time} ms" if @actual_time

      if @warnings.any?
        puts "\n🚩 Warnings and Suggestions:"
        @warnings.each do |warn|
          puts "  Line #{warn[:line_number]}: #{warn[:line_text]}"
          puts "    👉 #{warn[:suggestion]}"
        end
      else
        puts "\n✅ No immediate problems detected in the query plan."
      end
    end

    def self.classify_cost(cost)
      return unless cost

      case cost
      when 0..300
        puts "\n✅ Query cost is LOW. All good!"
      when 301..1000
        puts "\n🧐 Query cost is MODERATE. May benefit from optimizations."
      else
        puts "\n🛑 Query cost is HIGH. Recommend tuning immediately!"
      end
    end
  end
end
