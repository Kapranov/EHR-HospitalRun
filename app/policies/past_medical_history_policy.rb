class PastMedicalHistoryPolicy < BasePolicy

  def update?
    available?
  end

  def show?
    available?
  end
end
