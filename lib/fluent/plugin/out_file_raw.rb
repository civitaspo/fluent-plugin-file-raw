require "fluent/plugin/file/raw/version"

module Fluent
  class FileRawOutput < Output
    Plugin.register_output('file_raw', self)

    def initialize
      require 'time'
      require 'stringio'

      @start_time = Time.now.to_i
      super
    end

    def configure(conf)
      if path = conf['path']
        @path = path
      end
      unless @path
        fail ConfigError, "'path' parameter is required on file output"
      end

      super
    end

    def emit(tag, es, chain)

      date_hour = Time.now.strftime("%Y-%m-%d-%H")
      hash = rand(32).to_s
      path = "#{@path}.#{date_hour}.#{hash}"

      tag_ary = tag.split('.')

      if tag_ary[0] =~ /^bulk_hlog$/
        #
        # bulk_hlog.{JP_XX|KR}.{prod|dev|current}.** or bulk_hlog.ngpipes.{events|events_sandbox}.{jp|kr}**
        #
        if tag_ary[1] == 'ngpipes'
          es.each do | _time, record |
            if ! record.instance_of?(String)
              $log.error("record is not String")
              next
            end
            File.open(path, 'a') do |f|
              f.flock(File::LOCK_EX)
              StringIO.new(record, 'r').each do | line |
                f.write(line)
              end
            end
          end
        else
          region = tag_ary[1]
          env = tag_ary[2]

          es.each do | _time, record |
            if ! record.instance_of?(String)
              $log.error("record is not String")
              next
            end
            File.open(path, 'a') do |f|
              f.flock(File::LOCK_EX)
              StringIO.new(record, 'r').each do | line |
                str = "#{region}.#{env}." << line
                f.write(str)
              end
            end
          end
        end

      else
        #
        # hlog.{JP_XX|KR}.** or ngpipes.**
        #
        if tag_ary[0] != 'ngpipes'
          region = tag_ary[1]
          env = tag_ary[2]
        end

        File.open(path, 'a') do |f|
          f.flock(File::LOCK_EX)
          es.each do | _time, record |
            if ! record.instance_of?(Array)
              $log.error("record is not Array")
              next
            end
            if tag_ary[0] == 'ngpipes'
              str = record.join("\t") << "\n"
            else
              str = "#{region}.#{env}." << record.join("\t") << "\n"
            end
            f.write(str)
          end
        end
      end

      chain.next
    end
  end
end
