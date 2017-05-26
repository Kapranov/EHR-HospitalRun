shared_examples User::Trialable do
  it { should delegate_method(:trial_active?).to(:provider) }
  it { should delegate_method(:trial_period).to(:provider) }

  describe 'checkes whether provider on trial' do
    context 'returns true' do
      it 'has role :Provider and it is on trial' do
        create :provider, user_id: user.id
        allow(user).to receive(:role).and_return(:Provider)
        allow(user.provider).to receive(:trial?).and_return(true)
        expect(user.trial?).to eq true
      end
    end

    context 'returns false' do
      it 'has not role :Provider' do
        allow(user).to receive(:role).and_return(:Patient)
        expect(user.trial?).to eq false
      end

      it 'is not on trial' do
        allow(user).to receive(:role).and_return(:Provider)
        create :provider, user_id: user.id
        allow(user.provider).to receive(:trial?).and_return(false)
        expect(user.trial?).to eq false
      end
    end
  end
end