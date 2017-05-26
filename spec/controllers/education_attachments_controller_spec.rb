require 'spec_helper'

describe EducationAttachmentsController do
  clean_users

  let!(:provider)  { create :active_and_paid_provider }
  let!(:education_material) { create :education_material, provider_id:  provider.id }

  before :each do
    confirm_and_sign_in(provider.user)
  end

  describe 'GET #new' do
    it 'assigns new education_attachment' do
      get :new, education_material_id: education_material.id
      expect(assigns(:education_attachment)).to be_a_new EducationAttachment
    end

    it 'redirects to the education_attachment new view' do
      get :new, education_material_id: education_material.id
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) { attributes_for :education_attachment, education_material_id: education_material.id }

      it 'creates education_attachment' do
        expect {
          post :create, education_attachment: params
        }.to change { EducationAttachment.count }.by(1)
      end

      it 'redirects to the patient treatment view' do
        post :create, education_attachment: params
        expect(response).to redirect_to edit_education_material_path(education_material)
      end
    end

    # can't be invalid, oops)
    # context 'with invalid user params' do
    #   let(:params) { attributes_for :invalid_education_attachment, education_material_id: education_material.id, patient_id: patient.id }
    #
    #   it 'does not create education_attachment' do
    #     expect {
    #       post :create, education_attachment: params
    #     }.to_not change { EducationAttachment.count }
    #   end
    #
    #   it 'redirects to the education_attachment new view' do
    #     post :create, education_attachment: params
    #     expect(response).to redirect_to edit_education_material_path(education_material, patient_id: education_material.patient.id)
    #   end
    # end
  end

  describe 'works with existed education_attachment' do
    let!(:education_attachment) { create :education_attachment, education_material_id: education_material.id }

    describe 'DELETE #destroy' do
      it 'destroys education_attachment' do
        expect {
          delete :destroy, id: education_attachment, education_material_id: education_material.id
        }.to change { EducationAttachment.count }.by(-1)
      end

      it 'redirects to the patient treatment view' do
        delete :destroy, id: education_attachment, education_material_id: education_material.id
        expect(response.body).to be_blank
      end
    end
  end
end