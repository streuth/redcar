module Git
  
  class Status
    include Enumerable
    
    def initialize(base)
      @base = base
      construct_status
    end
    
    def changed
      @files.select { |k, f| f.type == 'M' }
    end
    
    def added
      @files.select { |k, f| f.type == 'A' }
    end

    def deleted
      @files.select { |k, f| f.type == 'D' }
    end
    
    def untracked
      @files.select { |k, f| f.untracked }
    end
    
    def all_changes
      @files
    end
    
    def pretty
      out = ''
      self.each do |file|
        out << file.path
        out << "\n\tsha(r) " + file.sha_repo.to_s + ' ' + file.mode_repo.to_s
        out << "\n\tsha(i) " + file.sha_index.to_s + ' ' + file.mode_index.to_s
        out << "\n\ttype   " + file.type.to_s
        out << "\n\tstage  " + file.stage.to_s
        out << "\n\tuntrac " + file.untracked.to_s
        out << "\n"
      end
      out << "\n"
      out
    end
    
    # enumerable method
    
    def [](file)
      @files[file]
    end
    
    def each(&block)
      @files.values.each(&block)
    end
    
    class StatusFile
      attr_accessor :path, :type, :type_raw, :stage, :untracked
      attr_accessor :mode_index, :mode_repo
      attr_accessor :sha_index, :sha_repo

      def initialize(base, hash)
        @base = base
        @path = hash[:path]
        @type = hash[:type]
        @type_raw = hash[:type_raw]
        @stage = hash[:stage]
        @mode_index = hash[:mode_index]
        @mode_repo = hash[:mode_repo]
        @sha_index = hash[:sha_index]
        @sha_repo = hash[:sha_repo]
        @untracked = hash[:untracked]
      end
      
      def blob(type = :index)
        if type == :repo
          @base.object(@sha_repo)
        else
          @base.object(@sha_index) rescue @base.object(@sha_repo)
        end
      end
      
      
    end
    
    private
    
      def construct_status
        files = @base.lib.status.find_all {|l| not l.nil?}
        @files = []

        files.each do |file_hash|
          status = file_hash[0, 2]
          path = file_hash[3, file_hash.length - 3]
          # If git quotes the filename, we need to expand it
          if status[0,1] == "R" or status[0,1] == "C"
            path = path.split(' -> ').map do |p|
              if p[0,1] == '"' and p[p.length-1,1] == '"'
                eval(p)
              else
                path
              end
            end.join(' -> ')
          else
            if path[0,1] == '"' and path[path.length-1,1] == '"'
              path = eval(path)
            end
          end
          file_hash = {:path => path, :type_raw => status}
          
          case status
          when '??'
            file_hash[:untracked] = true
          when 'M ', 'A '
            file_hash[:type] = 'A'
          when ' M', 'MM', 'AM', ' D', 'MD'
            file_hash[:type] = 'M'
          when 'D '
            file_hash[:type] = 'D'
          end
          
          @files.push([file_hash[:path], StatusFile.new(@base, file_hash)])
        end
      end
      
  end
  
end
