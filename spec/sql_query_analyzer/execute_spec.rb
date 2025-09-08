# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SqlQueryAnalyzer::Execute do
  describe '.explain_sql' do
    let(:raw_sql) { 'SELECT * FROM users' }
    let(:connection) { ActiveRecord::Base.connection }

    before do
      allow(connection).to receive(:execute)
    end

    context 'when run is false' do
      it 'executes EXPLAIN query' do
        expect(connection).to receive(:execute).with('EXPLAIN SELECT * FROM users')
        described_class.explain_sql(raw_sql, false)
      end
    end

    context 'when run is true' do
      it 'executes EXPLAIN ANALYZE query' do
        expect(connection).to receive(:execute).with('EXPLAIN ANALYZE SELECT * FROM users')
        described_class.explain_sql(raw_sql, true)
      end
    end
  end
end
