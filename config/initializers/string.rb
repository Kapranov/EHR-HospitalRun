class String
  def escape_cgi
    CGI.escape(self)
  end
end