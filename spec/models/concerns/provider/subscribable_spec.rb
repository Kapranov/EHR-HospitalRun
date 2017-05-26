shared_examples Provider::Subscribable do
  describe 'has alias' do
    let!(:provider) { create :provider, user_id: nil }

    it { expect(provider.method(:notify?).call).to  eq provider.notify }
  end

  describe 'adds to list' do
    let!(:provider) { create :provider }

    context 'notify sets as true' do
      before :each do
        allow(provider).to receive(:notify?).and_return(true)
      end

      it { expect(provider.add_to_subscribe_list['email_address']).to eq provider.user.email }
      it { expect(provider.add_to_subscribe_list['status']).to        eq 'subscribed' }
    end

    context 'notify sets as false' do
      before :each do
        allow(provider).to receive(:notify?).and_return(false)
      end

      it { expect(provider.add_to_subscribe_list).to be_a_nil }
    end
  end
end