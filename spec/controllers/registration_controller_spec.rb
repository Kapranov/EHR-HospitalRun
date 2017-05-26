require 'spec_helper'

describe RegistrationController do
  clean_users

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) { attributes_for(:user).merge(provider: attributes_for(:provider)) }

      it 'creates user' do
        expect {
          post :create, user: params
        }.to change { User.count }.by(1)
      end

      it 'associates provider with user' do
        post :create, user: params
        expect(User.where(email: params[:email]).first.provider).to eq Provider.last
      end

      it 'redirects to home page' do
        post :create, user: params
        expect(response).to redirect_to root_path
      end
    end

    context 'with invalid params' do
      let(:params) { attributes_for(:invalid_user).merge(provider: attributes_for(:provider)) }

      it 'does create any user' do
        expect {
          post :create, user: params
        }.to_not change { User.count }
      end

      it 'does create any provider' do
        expect {
          post :create, user: params
        }.to_not change { Provider.count }
      end

      it 'render registration#new' do
        post :create, user: params
        expect(response).to render_template :new
      end
    end
  end
end