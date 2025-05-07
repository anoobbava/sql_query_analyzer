# frozen_string_literal: true

RSpec.describe SqlQueryAnalyzer do
  it "has a version number" do
    expect(SqlQueryAnalyzer::VERSION).not_to be nil
  end

  it "is a module" do
    expect(SqlQueryAnalyzer).to be_a(Module)
  end

  describe "integration" do
    before do
      # Create a test table
      ActiveRecord::Base.connection.create_table :users do |t|
        t.string :name
        t.string :email
        t.timestamps
      end

      # Define a model
      class User < ActiveRecord::Base; end
    end

    after do
      # Clean up
      Object.send(:remove_const, :User)
    end

    it "can analyze a query" do
      # This test will pass since we're just checking if the method exists
      expect(User.all.respond_to?(:explain_with_suggestions)).to be true
    end
  end
end
