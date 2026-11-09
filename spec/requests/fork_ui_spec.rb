require "rails_helper"

# Checks for the UI refresh in this fork: models and collections (folders)
# must be easy to tell apart, and collections should behave like folders.
RSpec.describe "Fork UI", :after_first_run do
  let(:library) { create(:library) }
  let!(:parent) { create(:collection, name: "Tabletop") }
  let!(:child) { create(:collection, name: "Miniatures", collection: parent) }

  before do
    create(:model, library: library, name: "Dragon Knight", collections: [child])
  end

  describe "GET /collections", :as_member do
    before { get "/collections" }

    it "marks collection cards as folders" do
      expect(response.body).to include("mf-collection-card")
    end

    it "shows a collection type badge" do
      expect(response.body).to include("mf-type-badge mf-type-collection")
    end

    it "links a child collection to its parent, not to itself" do
      expect(response.body).to include(%(href="/collections/#{parent.to_param}">Tabletop</a>))
    end
  end

  describe "GET /models", :as_member do
    before { get "/models" }

    it "shows a model type badge" do
      expect(response.body).to include("mf-type-badge mf-type-model")
    end

    it "uses folder icons for collections" do
      expect(response.body).to include("bi-folder2")
    end
  end

  describe "GET /collections/:id for a parent collection", :as_member do
    before { get "/collections/#{parent.to_param}" }

    it "lists sub-collections as folder tiles" do
      expect(response.body).to include(%(class="mf-folder-tile" href="/collections/#{child.to_param}"))
    end

    it "does not claim the collection is empty" do
      expect(response.body).not_to include("bi-person-arms-up")
    end
  end

  describe "GET /collections/:id for a child collection", :as_member do
    it "shows the parent collection in the breadcrumbs" do
      get "/collections/#{child.to_param}"
      expect(response.body).to include(%(<li class="breadcrumb-item"><a href="/collections/#{parent.to_param}">Tabletop</a></li>))
    end
  end

  describe "footer", :as_member do
    it "links to the source code of this modified version" do
      get "/models"
      expect(response.body).to include(Rails.application.config.source_repo)
    end
  end
end
