require 'spec_helper'

describe Admin::UsersController do
  clean_users

  let!(:admin) { confirm_and_sign_in(create :admin) }

  describe 'GET #index' do
    before :each do
      create :active_and_paid_provider
      create :inactive_and_paid_provider
      create :inactive_and_trial_provider
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #new' do
    it 'renders the :new view' do
      xhr :get, :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'redirects to the :index view' do
        post :create, params_for_not_exist_user(:user, :provider)
        expect(response).to redirect_to :admin_users
      end
    end

    context 'with invalid user params' do
      it 'redirects to the :new view' do
        post :create, params_for_not_exist_user(:invalid_user, :provider)
        expect(response).to redirect_to :new_admin_user
      end
    end

    context 'with invalid provider params' do
      it 'redirects to the :new view' do
        post :create, params_for_not_exist_user(:user, :provider, :invalid_provider)
        expect(response).to redirect_to :new_admin_user
      end
    end
  end

  describe 'modify user' do
    let!(:provider) { create(:provider) }

    describe 'GET #edit' do
      it 'renders the :edit view' do
        xhr :get, :edit, id: provider.user
        expect(response).to render_template :edit
      end
    end

    describe 'PATCH #update' do
      context 'with valid params' do
        it 'redirects to the :index view' do
          patch :update, params_for_exist_user(provider.user)
          expect(response).to redirect_to :admin_users
        end
      end

      context 'with invalid provider params' do
        it 'redirects to the :edit view' do
          patch :update, params_for_exist_user(provider.user, :user, :invalid_provider)
          expect(response).to redirect_to edit_admin_user_url(id: provider.user)
        end
      end
    end

    describe 'GET #activate' do
      it 'renders the :activate view' do
        xhr :get, :activate, id: provider.user
        expect(response).to render_template :activate
      end
    end

    describe 'POST #activated' do
      it 'makes user active' do
        expect {
          post :activated, id: provider.user
        }.to change{ Provider.find(provider.id).active }
      end

      it 'redirects to the :index view' do
        post :activated, id: provider.user
        expect(response).to have_http_status 200
      end
    end

    describe 'GET #delete_confirmation' do
      it 'render the :delete_confirmation view' do
        xhr :get, :delete_confirmation, id: provider.user
        expect(response).to render_template :delete_confirmation
      end
    end

    describe 'DELETE #destroy' do
      it 'removes user' do
        expect {
          delete :destroy, id: provider.user
        }.to change(User, :count).by(-1)
      end

      it 'redirects to the :index view' do
        delete :destroy, id: provider.user
        expect(response).to have_http_status 200
      end
    end

    describe 'POST #pay' do
      let!(:provider) { create :active_and_trial_provider }

      it 'makes user paid' do
        expect {
          post :pay, id: provider.user
        }.to change{ Provider.find(provider.id).trial }
      end

      it 'redirects to the :index view' do
        post :pay, id: provider.user
        expect(response).to have_http_status 200
      end
    end

    describe 'POST #trial' do
      it 'makes user trial' do
        expect {
          post :trial, id: provider.user
        }.to change{ Provider.find(provider.id).trial }
      end

      it 'redirects to the :index view' do
        post :trial, id: provider.user
        expect(response).to have_http_status 200
      end
    end
  end
end