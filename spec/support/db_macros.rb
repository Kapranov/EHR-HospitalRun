module DbMacros
  def clean_users
    before :each do
      User.destroy_all
    end
  end
end