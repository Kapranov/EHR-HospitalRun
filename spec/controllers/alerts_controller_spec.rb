require 'spec_helper'

describe AlertsController do
  clean_users

  let!(:provider) { create :active_and_paid_provider }

  before :each do
    confirm_and_sign_in(provider.user)
  end

  describe 'GET #index' do
    before :each do
      Alert.destroy_all
      3.times { create :alert, provider_id: provider.id }
    end

    it 'assigns alerts' do
      get :index
      expect(assigns(:alerts).to_a).to eq Alert.all.to_a
    end

    it 'assigns rules' do
      get :index
      expect(assigns(:rules)).to eq Alert.rules
    end

    it 'renders index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    it 'assigns new alert' do
      get :new
      expect(assigns(:alert)).to be_a_new Alert
    end

    it 'assigns rules' do
      get :new
      expect(assigns(:rules)).to eq Alert.rules
    end

    it 'renders alert new view' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) { attributes_for :alert }

      it 'creates alert' do
        expect {
          post :create, alert: params
        }.to change { Alert.count }.by(1)
      end

      it 'redirects to the index view' do
        post :create, alert: params
        expect(response).to redirect_to alerts_path
      end
    end

    context 'with invalid user params' do
      let(:params) { attributes_for :invalid_alert }

      it 'does not create alert' do
        expect {
          post :create, alert: params
        }.to_not change { Alert.count }
      end

      it 'redirects to the alert new view' do
        post :create, alert: params
        expect(response).to redirect_to new_alert_path
      end
    end
  end

  describe 'works with existed alert' do
    let!(:alert) { create :alert }

    describe 'PATCH #update' do
      context 'with valid params' do
        let(:params)    { attributes_for :alert, id: alert.id }

        it 'updates alert' do
          patch :update, id: alert, alert: params
          expect(Alert.find(alert.id).description).to eq params[:description]
        end

        it 'renders nothing' do
          patch :update, id: alert, alert: params
          expect(response.body).to be_blank
        end
      end

      context 'with invalid params' do
        let(:params) { attributes_for :invalid_alert, id: alert.id }

        it 'does not update alert' do
          patch :update, id: alert, alert: params
          expect(Alert.find(alert.id).description).to_not eq params[:description]
        end

        it 'renders nothing' do
          patch :update, id: alert, alert: params
          expect(response.body).to be_blank
        end
      end
    end
  end
end