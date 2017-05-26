require 'spec_helper'

describe EducationMaterialsController do
  clean_users

  let!(:provider) { create :active_and_paid_provider }

  before :each do
    confirm_and_sign_in(provider.user)
  end

  describe 'GET #new' do
    it 'assigns new education_material' do
      get :new
      expect(assigns(:education_material)).to be_a_new EducationMaterial
    end

    it 'redirects to the education_material new view' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:params) { attributes_for :education_material }

      it 'creates education_material' do
        expect {
          post :create, education_material: params
        }.to change { EducationMaterial.count }.by(1)
      end

      it 'redirects to the patient treatment view' do
        post :create, education_material: params
        expect(response).to redirect_to education_materials_path
      end
    end

    context 'with invalid user params' do
      let(:params) { attributes_for :invalid_education_material }

      it 'does not create education_material' do
        expect {
          post :create, education_material: params
        }.to_not change { EducationMaterial.count }
      end

      it 'redirects to the education_material new view' do
        post :create, education_material: params
        expect(response).to redirect_to new_education_material_path
      end
    end
  end

  describe 'works with existed education_material' do
    let!(:education_material) { create :education_material }

    describe 'GET #edit' do
      it 'assigns the requested education_material' do
        get :edit, id: education_material
        expect(assigns(:education_material)).to eq education_material
      end

      it 'redirects to the education_material edit view' do
        get :edit, id: education_material
        expect(response).to render_template :edit
      end
    end

    describe 'PATCH #update' do
      context 'with valid params' do
        let(:params)    { attributes_for :education_material }

        it 'updates education_material' do
          patch :update, id: education_material, education_material: params
          expect(EducationMaterial.find(education_material.id).name).to eq params[:name]
        end

        it 'redirects to the patient treatment view' do
          patch :update, id: education_material, education_material: params
          expect(response).to redirect_to education_materials_path
        end
      end

      context 'with invalid params' do
        let(:params) { attributes_for :invalid_education_material }

        it 'does not update education_material' do
          patch :update, id: education_material, education_material: params
          expect(EducationMaterial.find(education_material.id).name).to_not eq params[:name]
        end

        it 'redirects to the education_material edit view' do
          patch :update, id: education_material, education_material: params
          expect(response).to redirect_to edit_education_material_path(education_material)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys education_material' do
        expect {
          delete :destroy, id: education_material
        }.to change { EducationMaterial.count }.by(-1)
      end

      it 'redirects to the patient treatment view' do
        delete :destroy, id: education_material
        expect(response.body).to be_blank
      end
    end
  end
end