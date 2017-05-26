require 'spec_helper'

describe AmendmentsController do
  clean_users

  let!(:provider) { create :active_and_paid_provider }
  let!(:patient)  { create :patient, provider_id: provider.id }

  before :each do
    confirm_and_sign_in(provider.user)
  end

  describe 'GET #new' do
    it 'assigns new amendment' do
      get :new, patient_id: patient.id
      expect(assigns(:amendment)).to be_a_new Amendment
    end

    it 'redirects to the amendment new view' do
      get :new, patient_id: patient.id
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) { attributes_for :amendment, patient_id: patient.id }

      it 'creates amendment' do
        expect {
          post :create, amendment: params
        }.to change { Amendment.count }.by(1)
      end

      it 'redirects to the patient treatment view' do
        post :create, amendment: params
        expect(response).to redirect_to patient_treatments_path(id: patient.id)
      end
    end

    context 'with invalid user params' do
      let(:params) { attributes_for :invalid_amendment, patient_id: patient.id }

      it 'does not create amendment' do
        expect {
          post :create, amendment: params
        }.to_not change { Amendment.count }
      end

      it 'redirects to the amendment new view' do
        post :create, amendment: params
        expect(response).to redirect_to new_amendment_path(patient_id: patient.id)
      end
    end
  end

  describe 'works with existed amendment' do
    let!(:amendment) { create :amendment, patient_id: patient.id }

    describe 'GET #edit' do
      it 'assigns the requested amendment' do
        get :edit, id: amendment, patient_id: patient.id
        expect(assigns(:amendment)).to eq amendment
      end

      it 'redirects to the amendment edit view' do
        get :edit, id: amendment, patient_id: patient.id
        expect(response).to render_template :edit
      end
    end

    describe 'PATCH #update' do
      context 'with valid params' do
        let(:params)    { attributes_for :amendment, patient_id: patient.id }

        it 'updates amendment' do
          patch :update, id: amendment, amendment: params
          expect(Amendment.find(amendment.id).description).to eq params[:description]
        end

        it 'redirects to the patient treatment view' do
          patch :update, id: amendment, amendment: params
          expect(response).to redirect_to patient_treatments_path(id: patient.id)
        end
      end

      context 'with invalid params' do
        let(:params) { attributes_for :invalid_amendment, patient_id: patient.id }

        it 'does not update amendment' do
          patch :update, id: amendment, amendment: params
          expect(Amendment.find(amendment.id).description).to_not eq params[:description]
        end

        it 'redirects to the amendment edit view' do
          patch :update, id: amendment, amendment: params
          expect(response).to redirect_to edit_amendment_path(amendment, patient_id: patient.id)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys amendment' do
        expect {
          delete :destroy, id: amendment, patient_id: patient.id
        }.to change { Amendment.count }.by(-1)
      end

      it 'redirects to the patient treatment view' do
        delete :destroy, id: amendment, patient_id: patient.id
        expect(response).to redirect_to patient_treatments_path(id: patient.id)
      end
    end
  end
end