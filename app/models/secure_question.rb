class SecureQuestion
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.questions
    [:'What was the last name of your first grade teacher?',
     :'Where were you when you had your first kiss?',
     :'Who was your childhood hero?',
     :'What is the last name of the teacher who gave you your first falling grade?']
  end

  field  :question,     type: Text
  field  :answer,       type: String

  belongs_to :patient

  def set?
    question.present?
  end

  def check_answer(user_answer)
    answer == user_answer
  end
end