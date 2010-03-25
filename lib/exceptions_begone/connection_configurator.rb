module ExceptionsBegone
  class ConnectionConfigurator

     # allowed configuration options for a project
     PROJECT_OPTIONS = [:project, :open_timeout, :read_timeout, :servers, :host, :port].freeze
     # each project can have a list of servers where exception will be send
     SERVER_OPTIONS = [:host, :port].freeze

     # default values for the configuration options
     DEFAULTS = { :project => "production",
                  :open_timeout => 5,
                  :read_timeout => 5,
                  :servers => [{:host => "127.0.0.1",
                                :port => 80}] }


     ## class instance

     def self.global_connection
       @@global_connection ||= ConnectionConfigurator.new( DEFAULTS.dup )
     end

     def self.global_connection= connection
       @@global_connection = connection
     end

    def self.global_parameters=(parameters = {})
      parameters = parameters.marshal_dump if parameters.respond_to?(:marshal_dump)
      self.global_connection = ConnectionConfigurator.build(parameters)
    end

     def self.build(parameters = {})
       parameters.blank? ? self.global_connection : new(parameters)
     end

     # just for compatibility
     def self.ostruct_to_hash(ostruct)
       server = { }

       val = PROJECT_OPTIONS.inject({ }) do |project, option|
         if(option != :host && option != :port && option != :servers)
           project[option] = ostruct.send(option) || DEFAULTS.dup[option]
         elsif option == :host || option == :port
           server[option] = ostruct.send(option) || DEFAULTS.dup[:servers][option]
         end
         project
       end

       if val[:servers].nil?
         SERVER_OPTIONS.each do |opt|
           val[opt] = server[opt] || DEFAULTS.dup[:servers][opt]
         end

         val[:servers] = [server]
       end
       val
     end

     def self.check_options_hash(options)
       if options[:host]  || options[:port]
         server = { }
         server[:host] = options[:host] || DEFAULTS.dup[:servers].first[:host]
         server[:port] = options[:port] || DEFAULTS.dup[:servers].first[:port]
         options[:servers] = [server]
       end
       options
     end
     ## ConnectionConfigurator instances.

     attr_accessor :project, :open_timeout, :read_timeout, :servers
     attr_writer :host, :port

     # Sample project description with two servers:
     #
     # { :project => "test_project",
     #   :open_timeout => 5,
     #   :read_timeout => 5,
     #   :servers => [ { :host => "localhost",
     #                   :port => 7070 },
     #                 { :host => "localhost",
     #                   :port => 7071 }]}
     def initialize(project = nil)
       @project_conf = if  project.nil?
                    ConnectionConfigurator::DEFAULTS.dup
                  else
                    project.instance_of?(Hash) ? ConnectionConfigurator.check_options_hash(project) : ConnectionConfigurator.ostruct_to_hash(project)
                  end


       (ConnectionConfigurator::PROJECT_OPTIONS + ConnectionConfigurator::SERVER_OPTIONS).each do |option|
         puts "OPTION:#{option} -> #{@project_conf[option]}"
         @project_conf[option] = @project_conf[option] || ConnectionConfigurator::DEFAULTS.dup[option]
         value = @project_conf[option]
         method = (option.to_s + "=").to_sym
         puts "WRITING: #{method}, #{value}"
         self.send(method, value)
       end
     end

     def path
       "/projects/#{@project_conf[:project]}/notifications"
     end

     def host
       @host || @servers.first[:host]
     end

     def port
       @port || @servers.first[:port]
     end
  end
end
