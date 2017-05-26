require 'openssl'
require 'socket'

class SendResult
  attr_reader :recipient
  attr_reader :succeeded
  attr_reader :message_id
  attr_reader :error_text

  def initialize(r, s, m)
    @recipient = r
    @succeeded = s
    if s
      @message_id = m
    else
      @error_text = m
    end
  end
end

class CheckResult
  attr_reader :mail
  attr_reader :message_id
  attr_reader :status_code
  attr_reader :info
  attr_reader :recipient
  attr_reader :sender
  attr_reader :num_attachments

  def initialize(m, id, sc, i, r, s, na)
    @mail = m
    @message_id = id
    @status_code = sc
    @info = i
    @recipient = r
    @sender = s
    @num_attachments = na
  end

  def self.new_status(id, status, info)
    self.new false, id, status, info, nil, nil, 0
  end

  def self.new_mail(r, s, num_attach, id)
    self.new true, id, nil, nil, r, s, num_attach
  end

  def is_mail?
    @mail
  end

  def is_status?
    !@mail
  end
end

class ShowResult
  attr_reader :part_num
  attr_reader :headers
  attr_reader :filename
  attr_reader :mime_type
  attr_reader :length
  attr_reader :data
  attr_reader :attachment_info

  def initialize(p, h, f, m, l, d, ai)
    @part_num = p
    @headers = h
    @filename = f
    @mime_type = m
    @length = l
    @data = d
    @attachment_info = ai
  end
end

class AttachmentInfo
  attr_reader :filename
  attr_reader :mime_type
  attr_reader :description

  def initialize(filename, mime_type, description)
    @filename = filename
    @mime_type = mime_type
    @description = description
  end
end

class PhiMailConnector

  @@VERSION = "1.0"
  @@BUILD = "104b"
  @@API_VERSION = "1.3.1"

  @@context = nil

  def initialize(s, p = 32541)
    if @@context.nil?
      @@context = OpenSSL::SSL::SSLContext.new
      @@context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      # @@context.ssl_version = "SSLv23_client"
    end

    tcp_client = TCPSocket.new s, p
    @ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, @@context
    @ssl_client.connect
    send_command "INFO VER RUBY #{@@VERSION}.#{@@BUILD}"
  end

  def self.set_server_certificate(filename)
    fail 'Set server certificate failed: invalid filename' if filename.nil?
    unless @@context.frozen?
      @@context = OpenSSL::SSL::SSLContext.new if @@context.nil?
      @@context.ca_file = filename
      @@context.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
  end

  def self.set_client_certificate(filename, passphrase = nil)
    fail 'Set client certificate failed: invalid filename' if anchor_cert.nil?
    @@context = OpenSSL::SSL::SSLContext.new if @@context.nil?
    @@context.cert = filename
    @@context.key = OpenSSL::PKey.read filename, passphrase
    @@context.verify_mode = OpenSSL::SSL::VERIFY_PEER
  end

  def close
    @ssl_client.close
  end

  def send_command(command)
    if !command.encoding.ascii_compatible? ||
        (command.encoding.name != 'UTF-8' && !command.ascii_only?)
      send_command 'INFO ERR invalid character encoding.'
      return 'FAIL invalid character encoding.'
    end
    if command.include?("\n") || command.include?("\r")
      send_command 'INFO ERR illegal characters in command string.'
      return 'FAIL illegal characters in command string.'
    end
    @ssl_client.puts command
    @ssl_client.flush
    puts command
    ans = @ssl_client.gets.try(:chomp)
    puts ans
    ans
  end

  def authenticate_user(user, pass = nil)
    response = send_command("AUTH #{user}" + extra_param(pass))
    fail "Authenication failed: #{response}" if response != 'OK'
  end

  def change_password(pass)
    response = send_command "PASS #{pass}"
    fail "Password change failed: #{response}" if response != 'OK'
  end

  def add_recipient(recipient)
    response = send_command "TO #{recipient}"
    fail "Add recipient failed: #{response}" if response != 'OK'
    @ssl_client.gets.chomp
  end

  def add_cc_recipient(recipient)
    response = send_command "CC #{recipient}"
    fail "Add CC recipient failed: #{response}" if response != 'OK'
    @ssl_client.gets.chomp
  end

  def clear
    response = send_command 'CLEAR'
    fail "Clear failed: #{response}" if response != 'OK'
  end

  def logout
    response = send_command 'LOGOUT'
    fail "Logout failed: #{response}" if response != 'OK'
  end

  def bye
    response = send_command 'BYE'
    fail "Bye failed: #{response}" if response != 'BYE'
  end

  def add_data(data, dataType, filename = nil, encoding = nil)
    if !encoding.nil? && (data.encoding.name != encoding || !data.valid_encoding?) &&
        (!data.encoding.ascii_compatible? || !data.ascii_only?)
      send_command 'INFO ERR invalid character encoding.'
      response = 'FAIL invalid character encoding.'
    else
      response = send_command("#{dataType} #{data.bytesize}" + extra_param(filename))
    end
    fail "Add #{dataType} failed: #{response}" if response != 'BEGIN'
    @ssl_client.write data
    @ssl_client.flush
    response = @ssl_client.gets.chomp
    fail ("Add #{dataType} failed:" + (response.nil? ? "" : response)) if response != 'OK'
  end

  def add_mime(data)
    add_data data, 'ADD MIME', nil, 'US-ASCII'
  end

  def add_cda(data, filename = nil)
    add_data data, 'ADD CDA', filename, 'UTF-8'
  end

  def add_xml(data, filename = nil)
    add_data data, 'ADD CDA', filename, 'UTF-8'
  end

  def add_ccr(data, filename = nil)
    add_data data, 'ADD CCR', filename, 'UTF-8'
  end

  def add_text(data, filename = nil)
    add_data data, 'ADD TEXT', filename, 'UTF-8'
  end

  def add_raw(data, filename = nil)
    add_data data, 'ADD RAW', filename
  end

  def set_subject(data = nil)
    response = send_command("SUBJECT" + extra_param(data))
    fail "Set subject failed: #{response}" if response != 'OK'
  end

  def set_delivery_notification(value)
    response = send_command('SET FINAL ' + (value ? '1' : '0'))
    fail "Set delivery notification failed: #{response}" if response != 'OK'
  end

  def send
    response = send_command 'SEND'
    fail "Send failed: #{response}" if response.start_with? 'FAIL'
    output = []
    while (!response.nil? && response != 'OK')
      r_explode = response.strip.split(' ', 4)
      case r_explode[0]
      when 'ERROR'
        output.push(SendResult.new(r_explode[1], false, r_explode[2]))
      when 'QUEUED'
        output.push(SendResult.new(r_explode[1], true, r_explode[2]))
      else
        fail "Send failed with unexpected response: #{response}"
      end
      response = send_command 'OK'
    end
    output
  end

  def check
    response = send_command 'CHECK'
    return nil if response == 'NONE'
    # fail "Check failed: #{response}" if response.start_with? 'FAIL'
    if response.start_with? 'STATUS'
      r_explode = response.strip.split(' ', 4)
      return CheckResult.new_status(r_explode[1], r_explode[2],
        r_explode.length == 4 ? r_explode[3] : nil)
    elsif response.start_with? 'MAIL'
      r_explode = response.strip.split(' ', 5)
      num_attach = Integer(r_explode[3])
      return CheckResult.new_mail(r_explode[1], r_explode[2], num_attach,
        r_explode[4])
    else
      # fail "Check failed with unexpected response:  #{response}"
    end
  end

  def acknowledge_status
    response = send_command 'OK'
    fail "Status acknowledgement failed: #{response}" if response != 'OK'
  end

  def acknowledge_message
    response = send_command 'DONE'
    fail "Message acknowlegement failed: #{response}" if response != 'OK'
  end

  def done
    acknowledge_message
  end

  def show(message_part)
    response = send_command "SHOW #{message_part}"
    fail "Show #{messagePart} failed: #{response}" if response != 'OK'
    headers = nil
    filename = nil
    if message_part.zero?
      headers = []
      while ((response=@ssl_client.gets.chomp)!=nil && response.length()>0) 
        headers.push response
      end
    else
      filename = @ssl_client.gets.chomp
    end

    mime_type = @ssl_client.gets.chomp
    length = Integer(@ssl_client.gets.chomp)
    buf = @ssl_client.read(length)
    fail "Show message content unexpected EOF" if buf.bytesize != length

    ai = nil
    if message_part.zero?
      num_attach = Integer(@ssl_client.gets.chomp)
      ai = Array.new(num_attach) {
        a_filename = @ssl_client.gets.chomp
        a_mime_type = @ssl_client.gets.chomp
        a_description = @ssl_client.gets.chomp
        AttachmentInfo.new(a_filename, a_mime_type, a_description)
      }
    end

    ShowResult.new(message_part, headers, filename, mime_type, length, buf, ai)
  end

  def search_directory(search_filter)
    response = send_command "LOOKUP JSON #{search_filter}"
    fail "Directory search failed: #{response}" if response != 'OK'

    num_results = Integer(@ssl_client.gets.chomp)
    search_results = Array.new(num_results) {
      @ssl_client.gets.chomp
    }
    search_results
  end

  def extra_param(s)
    (!s.nil? && !s.length.zero?) ? " #{s}" : ''
  end
end
