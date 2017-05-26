require 'spec_helper'

describe AdminSessionsController do
  clean_users

  describe 'GET #sign_in' do
    it 'assigns new User' do
      get :sign_in
      expect(assigns(:user)).to be_a_new User
    end

    it 'renders sign_in' do
      get :sign_in
      expect(response).to render_template :sign_in
    end
  end
end