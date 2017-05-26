module ControllerMacros
  def confirm_and_sign_in(user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user.confirm
    sign_in user
    user
  end

  def params_for_not_exist_user(user, person_sym, person = person_sym)
    person_params = { person_sym => attributes_for(person) }
    { user: attributes_for(user).merge(person_params) }
  end

  def params_for_exist_user(user, user_sym = nil, person_sym = nil)
    user_person_sym = user.role.to_s.downcase.to_sym
    person_sym = person_sym.present? ? person_sym : user_person_sym
    user_sym   = user_sym.present?   ? user_sym   : :user

    person_params = { }
    person_params.merge!({ user_person_sym => attributes_for(person_sym).merge({ id: user.person.id }) }) if user.person.present?
    { id: user, user: attributes_for(user_sym).merge(person_params) }
  end
end