class ProviderPolicy < BasePolicy
  def provider?
    current_user.role == :Provider
  end

  def admin?
    available?(__method__, [:Admin])
  end

  def main_provider?
    current_user.provider.practice_role == :Provider
  end
end
