
module Fluent
  class FileRawOutput < Output
    Plugin.register_output('file_raw', self)

    def initialize
      require 'time'
      require 'stringio'

      @start_time = Time.now.to_i
      super
    end

    config_param :output_path,        :string, :default => '/tmp/'
    config_param :output_file_prefix, :string, :default => 'fluent_out_file_raw'
    config_param :bulk_tag_prefix,    :string, :default => ''
    config_param :output_delimiter,   :string, :default => ''
    AVAILABLE_DELIMITERS =
      {
        'TAB' => "\t",
        'COMMA' => ',',
      }

    # To support log_level option implemented by Fluentd v0.10.43
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    # Define `router` method of v0.12 to support v0.10 or earlier
    unless method_defined?(:router)
      define_method("router") { Fluent::Engine }
    end

    def configure(conf)
      super

      unless Dir.exists?(@output_path)
        raise Fluent::ConfigError, "out_file_raw: `output_path` must be existed on this host."
      end
      @output_path_prefix = "#{@output_path}/#{@output_file_prefix}"

      unless @bulk_tag_prefix.empty?
        log.info "out_file_raw: bulk output mode ignores config `output_delimiter`."
      end

      if @output_delimiter.empty?
        @delimiter = ''
      else
        @delimiter = nil
        AVAILABLE_DELIMITERS.each do |key, value|
          if %r{#{key}}miu === @output_delimiter
            @delimiter = value
          end
        end

        unless @delimiter
          raise Fluent::ConfigError, "out_file_raw: `output_delimiter` must be one of available delimiters [#{AVAILABLE_DELIMITERS.keys.join(',')}]."
        end
      end

    end

    def emit(tag, es, chain)

      path = "#{@output_path_prefix}.#{date_hour}.#{hash}"

      if bulk?(tag)
        es.each do |_time, record|
          unless record.instance_of?(String)
            log.error("record is not String")
            next
          end
          open_and_lock(path) do |f|
            StringIO.new(record, 'r').each do |line|
              f.write(line)
            end
          end
        end
      else
        open_and_lock(path) do |f|
          es.each do |_time, record|
            unless record.instance_of?(Array)
              log.error("record is not Array")
              next
            end
            f.write(record_formatter(record))
          end
        end
      end

      chain.next
    end

    private

    def date_hour
      Time.now.strftime("%Y-%m-%d-%H")
    end

    def hash
      rand(32).to_s
    end

    def bulk?(tag)
      if @bulk_tag_prefix
        %r{^#{@bulk_tag_prefix}$} === tag.to_s.split('.')[0]
      else
        false
      end
    end

    def record_formatter(record)
      record.join(@delimiter) << "\n"
    end

    def open_and_lock(path)
      if block_given?
        File.open(path, 'a') do |f|
          f.flock(File::LOCK_EX)
          yield(f)
        end
      else
        raise RuntimeError, "out_file_raw: 'open_and_lock' method is available on block given context."
      end
    end
  end
end
