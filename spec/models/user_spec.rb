describe User do
  clean_users

  it { should validate_presence_of     :email }
  it { should validate_confirmation_of :password }
  it { should validate_presence_of     :role }

  it { should validate_length_of(:password).is_at_least(5) }
  it { should validate_length_of(:password_confirmation).is_at_least(5) }
  it { should validate_inclusion_of(:role).in_array(User.roles) }

  it { should delegate_method(:main_provider).to(:provider) }

  it 'is invalid with duplicated email' do
    create :user, email: 'user@gmail.com'
    expect(build(:user, email: 'user@gmail.com')).to_not be_valid
  end

  describe 'has default field values' do
    let(:email) { Faker::Internet.email }
    let!(:user) { create :user, email: email }

    it { expect(user.ip_locked).to  eq false }
    it { expect(user.locked).to     eq false }
    it { expect(user.two_factor).to eq true }
    it { expect(user.captcha).to    be_truthy }
    it { expect(user.to_label).to   eq email }
  end

  shared_examples 'a person' do
    it { expect(user.person).to eq person }
  end

  shared_examples 'a patient' do
    it { expect(user.patient).to eq patient }
  end


  shared_examples 'a checkable for being patient' do |result|
    it { expect(user.patient?).to be result }
  end

  shared_examples 'a checkable for being active' do
    it { expect(user.active?).to eq active? }
  end

  describe 'role :Provider' do
    let(:provider)  { create :provider }
    let(:user)      { provider.user }

    it_behaves_like 'a person' do
      let(:person)  { provider }
    end

    it_behaves_like 'a patient' do
      let(:patient) { nil }
    end

    it_behaves_like 'a checkable for being patient', false

    it_behaves_like 'a checkable for being active' do
      let(:active?) { provider.authenticable? }
    end
  end

  describe 'role :Patient', 'patient' do
    let(:patient)   { create :patient }
    let(:user)      { patient.user }

    it_behaves_like 'a person' do
      let(:person)  { patient }
    end

    it_behaves_like 'a patient'
    it_behaves_like 'a checkable for being patient', true

    it_behaves_like 'a checkable for being active' do
      let(:active?) { true }
    end
  end

  describe 'role :Admin' do
    let(:admin)     { create :admin }
    let(:user)      { admin }

    it_behaves_like 'a person' do
      let(:person)  { nil }
    end

    it_behaves_like 'a patient' do
      let(:patient) { nil }
    end

    it_behaves_like  'a checkable for being patient', false

    it_behaves_like 'a checkable for being active' do
      let(:active?) { true }
    end
  end

  describe 'role :Representative' do
    let(:representative) { create :representative }
    let(:user)           { representative.user }

    it_behaves_like 'a person' do
      let(:person)       { representative.patient }
    end

    it_behaves_like 'a patient' do
      let(:patient)      { representative.patient }
    end

    it_behaves_like 'a checkable for being patient', true

    it_behaves_like 'a checkable for being active' do
      let(:active?) { representative.active }
    end
  end

  describe 'instance methods' do
    let!(:user) { create :user }

    describe 'is allowed for authentication' do
      subject { user.active_for_authentication? }

      context 'when active and confirmed' do
        it 'returns true' do
          allow(user).to receive(:active?).and_return(true)
          user.confirm
          should be true
        end
      end

      context 'when inactive' do
        it 'returns false' do
          allow(user).to receive(:active?).and_return(false)
          user.confirm
          should be false
        end
      end

      context 'when not confirmed' do
        it 'returns false' do
          allow(user).to receive(:active?).and_return(true)
          should be false
        end
      end
    end

    describe 'bad enter message' do
      subject { user.inactive_message }

      it 'shows unconfirm message' do
        should eq :unconfirmed
      end

      it 'shows trial message' do
        user.confirm
        allow(user).to receive(:trial?).and_return(30)
        should eq 'Your 30-Day Trial version is finished'
      end

      it 'shows inactive message' do
        user.confirm
        allow(user).to receive(:trial?).and_return(nil)
        should eq 'Sorry, this account has been deactivated'
      end
    end

    describe 'id for email message' do
      context 'when role is not :Representative' do
        it 'returns user id' do
          expect(user.user_id_for_email_messages).to eq user.id
        end
      end

      context 'when role is :Representative' do
        it 'returns patient id' do
          user = create(:representative).user
          expect(user.user_id_for_email_messages).to eq user.patient.user.id
        end
      end
    end

    describe 'checking existence of alt email' do
      subject { user.alt_email? }

      context 'provider does not exist' do
        it 'returns false' do
          allow(user).to receive(:provider).and_return(nil)
          should eq false
        end
      end

      context 'provider does not have alt email' do
        it 'returns false' do
          create :provider, user_id: user.id
          allow(user.provider).to receive(:alt_email?).and_return(false)
          should eq false
        end
      end

      context 'provider has alt email' do
        it 'returns true' do
          create :provider, user_id: user.id
          should eq true
        end
      end
    end

    describe 'updates password' do
      let(:params) { { 'email' => Faker::Internet.email, 'password' => '123123', 'password_confirmation' => '123123' } }
      subject { user.update_password(params) }

      context 'invalid params returns false' do
        it 'has no email' do
          params['email'] = nil
          should eq false
        end

        it 'has no password' do
          params['password'] = nil
          should eq false
        end

        it 'has no password_confirmation' do
          params['password_confirmation'] = nil
          should eq false
        end

        it 'has different password and password_confirmation' do
          params['password_confirmation'] = '123124'
          should eq false
        end

        it 'has wrong permission access' do
          allow(user).to receive(:permission_valid?).and_return(false)
          should eq false
        end

        it 'has not found an email' do
          allow(user).to receive(:permission_valid?).and_return(false)
          should eq false
        end
      end

      context 'valid params' do
        it 'returns true' do
          params['email'] = user.email
          should eq true
        end
      end
    end

    describe 'checks permissions' do
      context 'returns false when updates not yourself' do
        subject { user.method(:permission_valid?).call(Faker::Internet.email) }

        it 'and does not have provider association' do
          should eq false
        end

        it 'and practice_role is not :Provider' do
          create :provider, user_id: user.id, practice_role: :Dentist
          should eq false
        end

        it 'and unkhown user' do
          create :provider, user_id: user.id, practice_role: :Provider
          should eq false
        end
      end

      context 'returns true' do
        it 'updates himself' do
          expect(user.method(:permission_valid?).call(user.email)).to eq true
        end

        it 'has practice_role equal to :Provider and updates one of his subproviders' do
          provider    = create :provider, user_id: user.id, practice_role: :Provider
          subprovider = create :provider, practice_role: :Dentist, provider_id: provider.id
          expect(user.method(:permission_valid?).call(subprovider.user.email)).to eq true
        end
      end
    end
  end

  describe 'includes modules' do
    let!(:user) { create :user }

    it_behaves_like User::Emailable
    it_behaves_like User::IpLockable
    it_behaves_like User::Trialable
  end
end
