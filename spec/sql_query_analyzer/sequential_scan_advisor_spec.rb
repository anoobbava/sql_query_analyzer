# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SqlQueryAnalyzer::SequentialScanAdvisor do
  before(:each) do
    ActiveRecord::Base.connection.create_table :test_users do |t|
      t.string :name
      t.string :email
      t.boolean :active
      t.timestamps
    end

    ActiveRecord::Base.connection.add_index :test_users, :email
    ActiveRecord::Base.connection.add_index :test_users, %i[name active]
  end

  after(:each) do
    ActiveRecord::Base.connection.drop_table :test_users if ActiveRecord::Base.connection.table_exists?(:test_users)
  end

  describe '#enhanced_message' do
    context 'when sequential scan is detected' do
      context 'with filter conditions' do
        let(:query_plan) do
          <<~PLAN
            Seq Scan on test_users  (cost=0.00..100.00 rows=1000 width=36)
              Filter: (name = 'John' AND active = true)
          PLAN
        end

        it 'returns a message with table and column information' do
          advisor = described_class.new(query_plan)
          expect(advisor.enhanced_message).to include("Sequential Scan detected on 'test_users'")
          expect(advisor.enhanced_message).to include('filter involves columns: name, active')
        end

        it 'suggests composite index when missing' do
          advisor = described_class.new(query_plan)
          expect(advisor.enhanced_message).not_to include('Consider adding a composite index')
        end
      end

      context 'without filter conditions' do
        let(:query_plan) do
          <<~PLAN
            Seq Scan on test_users  (cost=0.00..100.00 rows=1000 width=36)
          PLAN
        end

        it 'returns a message about full table read' do
          advisor = described_class.new(query_plan)
          expect(advisor.enhanced_message).to include("Sequential Scan detected on 'test_users'")
          expect(advisor.enhanced_message).to include('no filter condition found')
        end
      end
    end

    context 'when sequential scan is not detected' do
      let(:query_plan) do
        <<~PLAN
          Index Scan on test_users  (cost=0.00..100.00 rows=1000 width=36)
        PLAN
      end

      it 'returns nil' do
        advisor = described_class.new(query_plan)
        expect(advisor.enhanced_message).to be_nil
      end
    end
  end

  describe 'private methods' do
    let(:query_plan) do
      <<~PLAN
        Seq Scan on test_users  (cost=0.00..100.00 rows=1000 width=36)
          Filter: (name = 'John' AND active = true)
      PLAN
    end
    let(:advisor) { described_class.new(query_plan) }

    describe '#sequential_scan_detected?' do
      it 'returns true when Seq Scan is present' do
        expect(advisor.send(:sequential_scan_detected?)).to be true
      end

      it 'returns false when Seq Scan is not present' do
        advisor = described_class.new('Index Scan on test_users')
        expect(advisor.send(:sequential_scan_detected?)).to be false
      end
    end

    describe '#extract_table_and_columns' do
      it 'extracts table name and columns correctly' do
        table_name, columns = advisor.send(:extract_table_and_columns)
        expect(table_name).to eq('test_users')
        expect(columns).to match_array(%w[name active])
      end
    end

    describe '#missing_composite_index?' do
      it 'returns false when index exists' do
        expect(advisor.send(:missing_composite_index?, 'test_users', %w[name active])).to be false
      end

      it 'returns true when index does not exist' do
        expect(advisor.send(:missing_composite_index?, 'test_users', %w[email active])).to be true
      end
    end
  end
end
