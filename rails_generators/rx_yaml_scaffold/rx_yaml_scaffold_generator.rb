require 'yaml'

class RxYamlScaffoldGenerator < Rails::Generator::Base
  def extract_attrs(line, attrs)
    attrs.each do |key,value|
      if value.class == Array
        line << " #{key}:#{value.join(',')}"
      else
        line << " #{key}:#{value}"
      end    
    end
    line
  end
  
  def manifest
    record do |m|
      models = YAML.load(File.open(File.join(RAILS_ROOT, 'db/model.yml'), 'r'))
      models.each do |model|
        line = ""
        attrs = model[1]
        if attrs.class == Array
          attrs.each do |elm|
            line = extract_attrs(line, elm)
          end
        else
          line = extract_attrs(line, attrs)
        end
        line = model[0].camelcase + " " + line
        puts 'running: rx_scaffold ' + line
        Rails::Generator::Scripts::Generate.new.run(["rx_scaffold"] + line.split, 
          :flex_only => options[:flex_only],
          :flex_view_only => options[:flex_view_only],
          :rails_only => options[:rails_only],
          :distributed => options[:distributed])
        puts 'done ...'
        sleep 1
      end
      Rails::Generator::Scripts::Generate.new.run(["rx_config"], :main_only => true, 
        :skip_framework => options[:skip_framework])
    end
  end

  protected
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-f", "--flex-only", "Only generate the Flex/AIR files", 
      "Default: false") { |v| options[:flex_only] = v }
    opt.on("-r", "--rails-only", "Only generate the Rails files", 
      "Default: false") { |v| options[:rails_only] = v }
    opt.on("-fv", "--flex-view-only", "Only generate the Flex component files", 
      "Default: false") { |v| options[:flex_view_only] = v }
    opt.on("--distributed", "Creates migrations, controllers and models that use UUIDs and are distribution ready", 
      "Default: false") { |v| options[:distributed] = v }
    opt.on("--skip-framework", "Don't fetch the latest framework binary. You'll have to link/build the framework yourself.", 
      "Default: false") { |v| options[:skip_framework] = v }
  end
end
