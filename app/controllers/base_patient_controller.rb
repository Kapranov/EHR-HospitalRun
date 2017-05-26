class BasePatientController < ApplicationController
  before_action proc { redirect_to check_secure_questions_path }, if: proc { current_user.ip_locked? }
  before_action proc { redirect_to secure_questions_path },       if: :patient_with_secure_question?

  protected

  def patient_with_secure_question?
    current_user.patient? && !current_user.patient.secure_question.set?
  end
end