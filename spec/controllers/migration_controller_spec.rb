# frozen_string_literal: true

RSpec.describe MigrationController do
  describe 'GET index' do
    it 'renders the index HTML template' do
      get :index
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('text/html')
      expect(response).to render_template(:index)
    end
  end

  describe 'GET new' do
    it 'assigns @story with built associations' do
      get :new
      expect(assigns(:story)).to be_a(Story)
      expect(assigns(:story)).to be_new_record
      expect(assigns(:story).ore_aggregation.edm_aggregatedCHO).not_to be_nil
      expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dc_contributor_agent).not_to be_nil
      expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dc_subject_agents).not_to be_nil
      expect(assigns(:story).ore_aggregation.edm_isShownBy).not_to be_nil
    end

    it 'renders the new HTML template' do
      get :new
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('text/html')
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:params) {
        {
          story: {
            ore_aggregation_attributes: {
              edm_aggregatedCHO_attributes: {
                dc_title: 'title',
                dc_description: 'description',
                dc_contributor_agent_attributes: {
                  foaf_name: 'name',
                  foaf_mbox: 'me@example.org',
                  skos_prefLabel: 'me'
                }
              },
              edm_isShownBy_attributes: {
                media: fixture_file_upload(Rails.root.join('spec', 'support', 'media', 'image.jpg'), 'image/jpeg')
              }
            }
          }
        }
      }

      it 'saves the story' do
        expect { post :create, params: params }.not_to raise_exception
        expect(assigns(:story)).to be_valid
        expect(assigns(:story)).to be_persisted
      end

      it 'saves associations' do
        post :create, params: params
        expect(assigns(:story).ore_aggregation.edm_isShownBy).to be_valid
        expect(assigns(:story).ore_aggregation.edm_isShownBy).to be_persisted
      end

      it 'redirects to index' do
        post :create, params: params
        expect(response).to redirect_to(action: :index, c: 'eu-migration')
      end

      it 'saves defaults' do
        post :create, params: params
        expect(assigns(:story).ore_aggregation.edm_dataProvider).to eq('Europeana Foundation')
        expect(assigns(:story).ore_aggregation.edm_provider).to eq('Europeana Foundation')
      end

      describe 'place annotations' do
        before do
          params[:story][:ore_aggregation_attributes][:edm_aggregatedCHO_attributes][:dcterms_spatial_places_attributes] = place_attributes
        end

        context 'with both places' do
          let(:place_attributes) { [{ owl_sameAs: 'http://example.org/place/1' }, { owl_sameAs: 'http://example.org/place/2' }] }

          it 'saves them with skos:note' do
            post :create, params: params
            expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.size).to eq(2)
            expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.first.skos_note).to match(/began/)
            expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.last.skos_note).to match(/ended/)
          end
        end

        context 'with neither place' do
          let(:place_attributes) { [{ owl_sameAs: '' }, { owl_sameAs: '' }] }

          it 'does not save them' do
            post :create, params: params
            expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.size).to be_zero
          end
        end

        context 'with only begin' do
          let(:place_attributes) { [{ owl_sameAs: 'http://example.org/place/1' }, { owl_sameAs: '' }] }

          it 'saves it with skos:note' do
            post :create, params: params
            expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.size).to eq(1)
            expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.first.skos_note).to match(/began/)
          end
        end

        context 'with only end' do
          let(:place_attributes) { [{ owl_sameAs: '' }, { owl_sameAs: 'http://example.org/place/2' }] }

          it 'saves it with skos:note' do
            post :create, params: params
            expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.size).to eq(1)
            expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dcterms_spatial_places.first.skos_note).to match(/ended/)
          end
        end
      end

      it 'flashes a notification'
    end

    context 'with invalid params' do
      let(:params) {
        {
          story: {
            ore_aggregation_attributes: {
              edm_aggregatedCHO_attributes: {
                dc_contributor_agent_attributes: {
                  foaf_name: 'name',
                  foaf_mbox: 'me@example.org',
                  skos_prefLabel: 'me'
                }
              }
            }
          }
        }
      }

      it 'does not save the story' do
        post :create, params: params
        expect(assigns(:story)).not_to be_valid
        expect(assigns(:story)).not_to be_persisted
      end

      it 'does not save valid associations' do
        post :create, params: params
        expect(assigns(:story).ore_aggregation.edm_aggregatedCHO.dc_contributor_agent).not_to be_persisted
      end

      # it 'does not save invalid associations' do
      #   post :create, params: params
      #   expect(assigns(:story).edm_isShownBy).not_to be_valid
      #   expect(assigns(:story).edm_isShownBy).not_to be_persisted
      # end

      it 'renders the new HTML template' do
        post :create, params: params
        expect(response.status).to eq(400)
        expect(response.content_type).to eq('text/html')
        expect(response).to render_template(:new)
      end

      it 'shows error messages'
    end
  end
end
