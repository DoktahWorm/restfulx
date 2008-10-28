module Merb::Generators
  
  class RubossResourceControllerGenerator < NamespacedGenerator
    
    desc <<-DESC
      Generates a new ruboss resource controller.
    DESC
    
    option :testing_framework, :desc => 'Testing framework to use (one of: rspec, test_unit)'
    option :orm, :desc => 'Object-Relation Mapper to use (one of: none, activerecord, datamapper, sequel)'
    option :template_engine, :desc => 'Template Engine to use (one of: erb, haml, markaby, etc...)'
    
    first_argument :name, :required => true,
                          :desc     => "model name"
    second_argument :attributes, :as      => :hash,
                                 :default => {},
                                 :desc    => "space separated resource model properties in form of name:type. Example: state:string"
    
    invoke :helper do |generator|
      generator.new(destination_root, options, name)
    end
    
    # add controller and view templates for each of the four big ORM's

    template :controller_activerecord, :orm => :activerecord do |t|
      t.source = File.dirname(__FILE__) / "templates/ruboss_resource_controller/controller_ar.rb.erb"
      t.destination = "app/controllers" / base_path / "#{file_name}.rb"
    end

    template :controller_datamapper, :orm => :datamapper do |t|
      t.source = File.dirname(__FILE__) / "templates/ruboss_resource_controller/controller_dm.rb.erb"
      t.destination = "app/controllers" / base_path / "#{file_name}.rb"
    end
        
    template :controller_spec, :testing_framework => :rspec do |template|
      template.source = File.dirname(__FILE__) / 'templates/ruboss_resource_controller/spec/controllers/%file_name%_spec.rb'
      template.destination = "spec/controllers" / base_path / "#{file_name}_spec.rb"
    end

    template :request_spec, :testing_framework => :rspec do |template|
      template.source = File.dirname(__FILE__) / 'templates/ruboss_resource_controller/spec/requests/%file_name%_spec.rb'
      template.destination = "spec/requests" / base_path / "#{file_name}_spec.rb"
    end
    
    template :controller_test_unit, :testing_framework => :test_unit, :orm => :none do |template|
      template.source = File.dirname(__FILE__) / 'templates/ruboss_resource_controller/test/controllers/%file_name%_test.rb'
      template.destination = "test/controllers" / base_path / "#{file_name}_test.rb"
    end
    
    def model_class_name
      class_name.singularize
    end
    
    def plural_model
      class_name.snake_case
    end
    
    def singular_model
      plural_model.singularize
    end
    
    def resource_path
      chunks.map{ |c| c.snake_case }.join('/')
    end
    
    # TODO: fix this for Datamapper, so that it returns the primary keys for the model
    def params_for_get
      "params[:id]"
    end
    
    # TODO: implement this for Datamapper so that we get the model properties
    def properties
      []
    end
    
  end
  
  add :ruboss_resource_controller, RubossResourceControllerGenerator
  
end