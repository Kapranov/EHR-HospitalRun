class EmailMessagePolicy < BasePolicy
  def create?
    if current_user.patient?
      true
    else
      available?(__method__)
    end
  end

  def show?
    if current_user.patient?
      true
    else
      available?(__method__)
    end
  end
end
