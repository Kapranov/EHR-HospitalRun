class BasePolicy

  attr_reader :current_user, :record, :method_name

  def initialize(current_user, record)
    @current_user = current_user
    @record = record
  end

  def self.policies(*policies)
    policies.each do |policy|
      define_method policy do
        available?(__method__)
      end
    end
  end

  private

  def available?(method_name, roles = nil, doctor = nil)
    @method_name = method_name
    roles  ||= default_roles  # must be after @method_name = method_name
    doctor ||= default_doctor # must be after @method_name = method_name
    return false if @current_user.role   != :Provider
    return true  if doctor.practice_role == :Provider || (roles.include? 'Admin' && doctor.admin?) || doctor.emergency_access
    roles.include? doctor.practice_role.to_s
  end

  def policy_name
    "#{self.class.name}##{@method_name.present? ? @method_name : caller[0][/`([^']*)'/, 1]}"
  end

  def default_roles
    if default_doctor
      permission = @current_user.main_provider.permissions.where(policy_name: policy_name).first
      permission.present? ? permission.availabilities.where(available: true).map(&:role) : []
    else
      []
    end
  end

  def default_doctor
    @current_user.try(:provider)
  end
end