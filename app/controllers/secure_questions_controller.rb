class SecureQuestionsController < ApplicationController
  layout 'patients_secure_questions'

  before_action proc { authorize :Patient, :patient? },
                proc { @secure_question = current_user.patient.secure_question }

  def index
    @questions = SecureQuestion.questions
  end

  def check
  end

  def message
  end

  def edit
    @questions = SecureQuestion.questions
  end

  def verify
    if @secure_question.check_answer(params[:secure_question][:answer])
      current_user.unlock_ip
      redirect_to patients_path
    else
      flash[:error] = 'This answer is incorrect'
      redirect_to :back
    end
  end

  def update
    if @secure_question.set? && !@secure_question.check_answer(params[:answer])
      flash[:error] = 'Wrong answer'
      redirect_to :back
    else
      if @secure_question.update(secure_question_params)
        flash[:notice] = updation_notification(@secure_question)
        redirect_to patients_path
      else
        flash[:error] = @secure_question.errors.full_messages.to_sentence
        redirect_to :back
      end
    end
  end

  protected

  def secure_question_params
    params.require(:secure_question).permit(
      :question,
      :answer
    )
  end
end