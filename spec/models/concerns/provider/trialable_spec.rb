shared_examples Provider::Trialable do
  context 'trial provider' do
    let!(:provider) { create :provider, user_id: nil, trial: 30 }

    it { expect(provider.trial?).to eq true }

    it { expect(provider.trial_5?).to eq false }
    it 'is 5 trial' do
      allow(provider).to receive(:trial_period).and_return(5)
      expect(provider.trial_5?).to eq true
    end

    it { expect(provider.trial_20?).to eq false }
    it 'is 20 trial' do
      allow(provider).to receive(:trial_period).and_return(20)
      expect(provider.trial_20?).to eq true
    end

    it { expect(provider.trial_active?).to eq true }
    it { expect(provider.trial_period).to  eq 30 }

    describe 'goes to paid' do
      before :each do
        provider.update(user_id: create(:user).id)
      end

      subject { proc { provider.to_paid } }

      it { should change { Provider.find(provider.id).trial }.from(30).to(nil)  }
      it { should change { AdminNotifierMailer.deliveries.count } }
      it { should change { SelfNotifierMailer.deliveries.count } }
    end
  end

  context 'paid provider' do
    let!(:provider) { create :provider }

    it { expect(provider.trial?).to        eq false }
    it { expect(provider.trial_5?).to      eq false }
    it { expect(provider.trial_20?).to     eq false }
    it { expect(provider.trial_active?).to eq false }
    it { expect(provider.trial_period).to  eq 0 }
    describe 'goes to trial' do
      before :each do
        provider.update(user_id: create(:user).id)
      end

      subject { proc { provider.to_trial } }

      it { should change { Provider.find(provider.id).trial }.from(nil).to(30)  }
      it { should change { AdminNotifierMailer.deliveries.count } }
      it { should change { SelfNotifierMailer.deliveries.count } }
    end
  end
end