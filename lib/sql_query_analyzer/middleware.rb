# frozen_string_literal: true

module SqlQueryAnalyzer
  class Middleware
    def initialize(app)
      @app = app
      @analyzing = false
    end

    def call(env)
      return @app.call(env) unless SqlQueryAnalyzer.enabled_for_current_env?

      # Subscribe to SQL events
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        if event.payload[:sql].present?
          if SqlQueryAnalyzer.configuration.analyze_mode == :async
            Thread.new { analyze_query(event) }
          else
            analyze_query(event)
          end
        end
      end

      @app.call(env)
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
    end

    private

    def analyze_query(event)
      sql = event.payload[:sql]
      return if sql.blank? || SqlQueryAnalyzer.configuration.should_skip_query?(sql) || @analyzing

      begin
        @analyzing = true
        # Use a separate connection to avoid transaction issues
        connection = ActiveRecord::Base.connection_pool.checkout
        begin
          # Set statement timeout
          connection.execute("SET statement_timeout = #{SqlQueryAnalyzer.configuration.timeout * 1000}")
          result = connection.execute("#{SqlQueryAnalyzer.configuration.explain_command} #{sql}")
          analyzer = SuggestionEngine.new(result, sql)
          warnings = analyzer.analyze

          log_analysis(sql, warnings) if warnings.any?
        ensure
          # Reset statement timeout
          connection.execute("SET statement_timeout = DEFAULT")
          ActiveRecord::Base.connection_pool.checkin(connection)
        end
      rescue => e
        SqlQueryAnalyzer.logger.error("SQL Query Analyzer Error: #{e.message}")
      ensure
        @analyzing = false
      end
    end

    def log_analysis(sql, warnings)
      message = [
        "\n=== SQL Query Analysis ===",
        "Query: #{sql}",
        "Warnings:",
        warnings.map { |w| "  - #{w[:suggestion]}" }.join("\n"),
        "=======================\n"
      ].join("\n")

      SqlQueryAnalyzer.logger.send(SqlQueryAnalyzer.configuration.log_level, message)
    end
  end
end 