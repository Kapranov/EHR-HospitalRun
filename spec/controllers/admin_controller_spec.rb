require 'spec_helper'

describe AdminController do
  clean_users

  let!(:admin) { confirm_and_sign_in(create :admin) }

  describe 'GET #index' do
    let(:provider) { create :provider }

    it 'populates an array of all providers' do
      get :index
      expect(assigns(:providers)).to include provider
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
  end
end