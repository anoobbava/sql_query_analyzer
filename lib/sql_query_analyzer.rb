# lib/sql_query_analyzer.rb
require "active_support/all"
require "active_record"

require "sql_query_analyzer/version"
require "sql_query_analyzer/suggestion_engine"
require "sql_query_analyzer/explain_analyzer"
require "sql_query_analyzer/execute"
require "sql_query_analyzer/sequential_scan_advisor"
require "sql_query_analyzer/configuration"
require "sql_query_analyzer/middleware"
require "sql_query_analyzer/railtie" if defined?(Rails)

module SqlQueryAnalyzer
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def enabled?
      configuration.enabled
    end

    def logger
      configuration.logger
    end

    def enabled_for_current_env?
      configuration.enabled_for_current_env?
    end
  end

  # Future configurations can go here
end
