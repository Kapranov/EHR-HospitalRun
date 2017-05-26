describe Provider do
  clean_users

  it { should validate_inclusion_of(:title).in_array(Provider.titles) }
  it { should validate_inclusion_of(:practice_role).in_array(Provider.practice_roles) }
  it { should validate_inclusion_of(:degree).in_array(Provider.degrees) }
  it { should validate_inclusion_of(:speciality).in_array(Provider.specialities) }


  describe 'has default field values' do
    let!(:provider) { create :provider, user_id: nil }

    it { expect(provider.admin).to                 eq false }
    it { expect(provider.emergency_access).to      eq false }
    it { expect(provider.accepting_patient).to     eq false }
    it { expect(provider.enable_online_booking).to eq false }
    it { expect(provider.active).to                eq false }
    it { expect(provider.notify).to                eq false }

    describe 'creates helper models' do
      it { expect(provider.schedule_general).to       be_truthy }
      it { expect(provider.erx).to                    be_truthy }
      it { expect(provider.payment).to                be_truthy }
      it { expect(provider.payment_agreement_sign).to be_truthy }
      it { expect(provider.trigger_categories).to_not be_empty }
    end

    describe 'has permissions' do
      context 'practice role is :Provider' do
        it { expect(provider.permissions).to_not be_empty }
      end

      context 'practice role is not :Provider' do
        let!(:dentist) { create :provider, user_id: nil, practice_role: :Dentist }

        it { expect(dentist.permissions).to     be_empty }
      end
    end
  end

  describe 'has aliases' do
    let!(:provider) { create :provider, user_id: nil }

    it { expect(provider.admin?).to  eq provider.admin }
    it { expect(provider.active?).to eq provider.active }
  end

  describe 'has scopes' do
    let!(:provider) { create :active_and_paid_provider, user_id: nil }
    let!(:dentist)  { create :inactive_and_trial_provider, practice_role: :Dentist }

    context 'scope active' do
      subject { Provider.active }

      it { should     include(provider) }
      it { should_not include(dentist) }
    end

    context 'scope pending' do
      subject { Provider.pending }

      it { should     include(dentist) }
      it { should_not include(provider) }
    end

    context 'scope paid' do
      subject { Provider.paid }

      it { should     include(provider) }
      it { should_not include(dentist) }
    end

    context 'scope providers' do
      subject { Provider.providers }

      it { should     include(provider) }
      it { should_not include(dentist) }
    end
  end

  describe 'instance methods' do
    let!(:provider) { create :provider, user_id: nil }

    it { expect(provider.to_label).to eq "#{provider.title} #{provider.last_name} #{provider.first_name}" }
    it { expect(provider.full_name).to eq "#{provider.first_name} #{provider.last_name}" }

    describe 'checks whether provider authenticable' do
      subject { provider.authenticable? }

      context 'returns true' do
        it 'is active and paid' do
          allow(provider).to receive(:active?).and_return(true)
          allow(provider).to receive(:trial?).and_return(false)
          should eq true
        end

        it 'is active and on active trial' do
          allow(provider).to receive(:active?).and_return(true)
          allow(provider).to receive(:trial?).and_return(true)
          allow(provider).to receive(:trial_active?).and_return(true)
          should eq true
        end
      end

      context 'returns false' do
        it 'is inactive' do
          allow(provider).to receive(:active?).and_return(false)
          should eq false
        end

        it 'is active and trial has finished' do
          allow(provider).to receive(:active?).and_return(false)
          allow(provider).to receive(:trial?).and_return(true)
          allow(provider).to receive(:trial_active?).and_return(false)
          should eq false
        end
      end
    end

    describe 'checks alt email existance' do
      subject { provider.alt_email? }
      it 'is exist' do
        allow(provider).to receive(:alt_email).and_return(Faker::Internet.email)
        should eq true
      end

      it 'is not exist' do
        allow(provider).to receive(:alt_email).and_return(nil)
        should eq false
      end
    end
  end

  it_behaves_like Notifiable, :provider

  it_behaves_like Provider::Activatable
  it_behaves_like Provider::Majorizable
  it_behaves_like Provider::SmsNotifiable
  it_behaves_like Provider::Subscribable
  it_behaves_like Provider::Trialable

  it_behaves_like Collectionable, [
      :appointment_statuses,
      :appointment_types,
      :locations,
      :patients,
      :providers,
      :trigger_categories,
      :referrals,
      :rooms] do
    let!(:obj) { create :provider, user_id: nil }
  end

  it_behaves_like Searchable, [:patients] do
    let!(:obj) { create :provider, user_id: nil }
  end

  it_behaves_like 'an instance searchable'
end