# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SqlQueryAnalyzer::ExplainAnalyzer do
  let(:dummy_relation) { Class.new { include SqlQueryAnalyzer::ExplainAnalyzer } }

  before(:all) do
    ActiveRecord::Base.connection.create_table :test_users do |t|
      t.string :name
      t.string :email
      t.timestamps
    end

    class TestUser < ActiveRecord::Base; end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table :test_users if ActiveRecord::Base.connection.table_exists?(:test_users)
    Object.send(:remove_const, :TestUser) if Object.const_defined?(:TestUser)
  end

  describe '#explain_with_suggestions' do
    context 'when called on a non-ActiveRecord::Relation' do
      it 'returns nil and outputs a warning' do
        instance = dummy_relation.new
        expect { instance.explain_with_suggestions }.to output(/⚠️ Not an ActiveRecord Relation/).to_stdout
      end
    end

    context 'when called on an ActiveRecord::Relation' do
      let(:relation) { TestUser.all }

      before do
        allow(relation).to receive(:to_sql).and_return('SELECT * FROM test_users')
        allow(SqlQueryAnalyzer::Execute).to receive(:explain_sql).and_return('EXPLAIN output')
        allow_any_instance_of(SqlQueryAnalyzer::SuggestionEngine).to receive(:analyze).and_return([])
      end

      it 'calls explain_sql with the correct SQL' do
        expect(SqlQueryAnalyzer::Execute).to receive(:explain_sql).with('SELECT * FROM test_users', false)
        relation.explain_with_suggestions
      end

      it 'creates a SuggestionEngine with the explain output' do
        expect(SqlQueryAnalyzer::SuggestionEngine).to receive(:new).with('EXPLAIN output', 'SELECT * FROM test_users')
        relation.explain_with_suggestions
      end

      it 'calls analyze on the SuggestionEngine' do
        engine = instance_double(SqlQueryAnalyzer::SuggestionEngine)
        allow(SqlQueryAnalyzer::SuggestionEngine).to receive(:new).and_return(engine)
        expect(engine).to receive(:analyze)
        relation.explain_with_suggestions
      end
    end

    context 'when an error occurs' do
      let(:relation) { TestUser.all }

      before do
        allow(relation).to receive(:to_sql).and_raise(StandardError.new('Test error'))
      end

      it 'catches the error and outputs the message' do
        expect { relation.explain_with_suggestions }.to output(/Error analyzing query: Test error/).to_stdout
      end
    end
  end
end
