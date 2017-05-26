module ModelLogger
  LOG_PATH = "#{ Rails.root.to_s }/log" unless const_defined? :LOG_PATH

  def create_log(object)
    check_dir(object)

    File.open(file_name(object), 'w') do |f|
      f.puts("Provider #{ current_user.provider.full_name } with id #{ current_user.provider.id } create #{ object.class.name.downcase } at #{ Time.now }")
      f.puts
    end
  end

  def update_log(object)
    check_dir(object)
    File.open(file_name(object), 'a+') do |f|
      f.puts("Provider #{ current_user.provider.full_name } with id #{ current_user.provider.id } change")
      params[object.class.name.downcase].keys.each do |key|
        if object.class.fields.keys.include? key.to_sym
          if params[object.class.name.downcase][key].to_s != object.send(key).to_s
            f.puts "#{ key } from '#{ object.send(key).to_s }' to '#{ params[object.class.name.downcase][key].to_s }'"
          end
        end
      end
      f.puts("at #{ Time.now }")
      f.puts
    end
  end

  def remove_log(object)
    check_dir(object)
    File.delete(file) if File.exist?(file_name(object))
  end

  def read_log(object)
    check(object)
    contentsArray = []
    puts file_name(object)
    File.open(file_name(object)) { |f| f.each_line {|line| contentsArray.push(line) } }
    contentsArray
  end

  def file_name(object)
    LOG_PATH + "/#{ object.class.name }/#{ object.id }.txt"
  end

  def check(object)
    check_dir(object)
    check_file(object)
  end

  def check_dir(object)
    dir_name = LOG_PATH + "/#{ object.class.name }"
    Dir.mkdir(dir_name) unless File.directory?(dir_name)
  end

  def check_file(object)
    File.open(file_name(object), 'w') unless File.exist?(file_name(object))
  end
end