# frozen_string_literal: true

require "rails"

module SqlQueryAnalyzer
  class Railtie < Rails::Railtie
    initializer "sql_query_analyzer.insert_middleware" do |app|
      app.config.middleware.use SqlQueryAnalyzer::Middleware
    end

    config.after_initialize do
      SqlQueryAnalyzer.configure do |config|
        config.logger = Rails.logger
        config.environments = [:development]
      end
    end
  end
end 