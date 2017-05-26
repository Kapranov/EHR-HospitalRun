module User::WithoutEmail
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def generate_default_email
      "no_email@#{(1..6).to_a.map{ ('a'..'z').to_a.sample }.join  }.com"
    end
  end
end