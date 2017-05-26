shared_examples User::IpLockable do
  describe 'checks whether it is a first enter' do
    context 'returns true' do
      it 'has role :Patient and secure question is not set' do
        create(:patient, user_id: user.id)
        allow(user).to receive(:role).and_return(:Patient)
        expect(user.first_enter?).to eq true
      end
    end

    context 'returns false' do
      it 'has not role :Patient' do
        allow(user).to receive(:role).and_return(:Provider)
        expect(user.first_enter?).to eq false
      end

      it 'secure question is set' do
        create(:patient, user_id: user.id)
        allow(user).to receive(:role).and_return(:Patient)
        allow(user.patient.secure_question).to receive(:set?).and_return(true)
        expect(user.first_enter?).to eq false
      end
    end
  end

  describe 'checks whether user should be locked by ip' do
    let(:ip) { '127.0.0.1' }

    context 'returns true' do
      it 'has role :Patient and ip has changed' do
        allow(user).to receive(:role).and_return(:Patient)
        allow(user).to receive(:last_sign_in_ip).and_return('127.0.0.2')
        expect(user.locked_ip?(ip)).to eq true
      end
    end

    context 'returns false' do
      it 'has not role :Patient' do
        allow(user).to receive(:role).and_return(:Provider)
        expect(user.locked_ip?(ip)).to eq false
      end

      it 'enters for the first time' do
        allow(user).to receive(:role).and_return(:Patient)
        allow(user).to receive(:last_sign_in_ip).and_return(nil)
        expect(user.locked_ip?(ip)).to eq false
      end

      it 'has not change ip' do
        allow(user).to receive(:role).and_return(:Patient)
        allow(user).to receive(:last_sign_in_ip).and_return('127.0.0.1')
        expect(user.locked_ip?(ip)).to eq false
      end
    end
  end

  describe 'updates ip' do
    context 'ip presents' do
      let(:ip) { '127.0.0.1' }

      it 'changes ip_locked' do
        allow(user).to receive(:locked_ip?).and_return(true)
        expect{ user.update_ip(ip) }.to change{ user.ip_locked }
      end

      it 'changes current_sign_in_ip' do
        expect{ user.update_ip(ip) }.to change{ user.current_sign_in_ip }
      end

      it 'changes last_sign_in_ip' do
        expect{ user.update_ip(ip) }.to change{ user.last_sign_in_ip }
      end
    end

    context 'ip does not present' do
      it 'does not changed' do
        expect{ user.update_ip(nil) }.to_not change{ user }
      end
    end
  end

  it 'unlockes ip' do
    user.update(ip_locked: true)
    expect{ user.unlock_ip }.to change{ user.ip_locked }.from(true).to(false)
  end
end