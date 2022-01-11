require "rails_helper"

class ModelLoadingService
    def initialize(searchable_model, params = {})
      @searchable_model = searchable_model
      @params = params
      @params ||= {}
    
    def call
        @searchable_model.search_by_name(@params.dig(:search, :name))
                         .order(@params[:order].to_h)
                         .paginate(@params[:page].to_i, @params[:length].to_i)
      end

describe Admin::ModelLoadingService do
    context "when #call" do
        let!(:categories) { create_list(:category, 15) }
    
        context "when params are present" do
            let!(:search_categories) do
              categories = []
              15.times { |n| categories << create(:category, name: "Search #{n + 1}") }
              categories
            end
          
            let(:params) do
              { search: { name: "Search" }, order: { name: :desc }, page: 2, length: 4 }
            end

            it "returns right :length following pagination" do
                service = described_class.new(Category.all, params)
                result_categories = service.call
                expect(result_categories.count).to eq 4
              end
            end

            it "returns records following search, order and pagination" do
                search_categories.sort! { |a, b| b[:name] <=> a[:name] }
                service = described_class.new(Category.all, params)
                result_categories = service.call
                expected_categories = search_categories[4..7]
                expect(result_categories).to contain_exactly *expected_categories
              end
            end
          end
    
          context "when params are not present" do
            it "returns default :length pagination" do
              service = described_class.new(Category.all, nil)
              result_categories = service.call
              expect(result_categories.count).to eq 10
            end
          
            it "returns first 10 records" do
              service = described_class.new(Category.all, nil)
              result_categories = service.call
              expected_categories = categories[0..9]
              expect(result_categories).to contain_exactly *expected_categories
            end
          end
      end
    end