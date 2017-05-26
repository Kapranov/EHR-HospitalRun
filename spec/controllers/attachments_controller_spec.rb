require 'spec_helper'

describe AttachmentsController do
  clean_users

  let!(:provider)  { create :active_and_paid_provider }
  let!(:patient)   { create :patient,   provider_id: provider.id }
  let!(:amendment) { create :amendment, patient_id:  patient.id }

  before :each do
    confirm_and_sign_in(provider.user)
  end

  describe 'GET #new' do
    it 'assigns new attachment' do
      get :new, amendment_id: amendment.id, patient_id: patient.id
      expect(assigns(:attachment)).to be_a_new Attachment
    end

    it 'redirects to the attachment new view' do
      get :new, amendment_id: amendment.id, patient_id: patient.id
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) { attributes_for :attachment, amendment_id: amendment.id, patient_id: patient.id }

      it 'creates attachment' do
        expect {
          post :create, attachment: params
        }.to change { Attachment.count }.by(1)
      end

      it 'redirects to the patient treatment view' do
        post :create, attachment: params
        expect(response).to redirect_to edit_amendment_path(amendment, patient_id: amendment.patient.id)
      end
    end

    # can't be invalid, oops)
    # context 'with invalid user params' do
    #   let(:params) { attributes_for :invalid_attachment, amendment_id: amendment.id, patient_id: patient.id }
    #
    #   it 'does not create attachment' do
    #     expect {
    #       post :create, attachment: params
    #     }.to_not change { Attachment.count }
    #   end
    #
    #   it 'redirects to the attachment new view' do
    #     post :create, attachment: params
    #     expect(response).to redirect_to edit_amendment_path(amendment, patient_id: amendment.patient.id)
    #   end
    # end
  end

  describe 'works with existed attachment' do
    let!(:attachment) { create :attachment, amendment_id: amendment.id }

    describe 'DELETE #destroy' do
      it 'destroys attachment' do
        expect {
          delete :destroy, id: attachment, amendment_id: amendment.id, patient_id: patient.id
        }.to change { Attachment.count }.by(-1)
      end

      it 'redirects to the patient treatment view' do
        delete :destroy, id: attachment, amendment_id: amendment.id, patient_id: patient.id
        expect(response).to redirect_to edit_amendment_path(amendment, patient_id: amendment.patient.id)
      end
    end
  end
end