module MrubyMix

  class Processor

    attr_reader :root_file_name, :dest_file_name
    attr_accessor :results

    def initialize(root_file_name, dest_file_name)
      @root_file_name = root_file_name
      @dest_file_name = dest_file_name
      @results = []
    end

    # mix all source files trackable from the root file
    def mix
      process_files(File.expand_path(root_file_name))

      File.open(dest_file_name, "w") do |o_f|
        results.each do |name, skip_lines|
          File.open(name, "r") do |i_f|
            o_f.write "\# File: #{name}\n"
            i_f.each do |l|
              # skip_lines is sorted
              if i_f.lineno == skip_lines.first
                skip_lines.shift
              else
                o_f.write l
              end
            end
            o_f.write "\n"
          end
        end
      end
    end

    private

    # Processes a single file and returned all required items with line numbers
    # and item name in the following format:
    #
    #   [[2, "require", "foo"], [3, "require", "bar"]]
    #
    def parse_single_file(file_name)
      r = []
      File.open(file_name, "r") do |f|
        f.each do |l|
          words = l.split(' ').select {|w| !w.empty? }
          if (words.length == 3) &&
              (words[0] == '#=')
            r <<= [f.lineno, words[1], words[2]]
          end
        end
      end
      r
    end

    def file_not_processed(full_file_name)
      results.none? {|r| r[0] == full_file_name}
    end

    def normalize_file_name(file_name, base_dir)
      file_name = File.expand_path(file_name, base_dir)
      file_name <<= '.rb' unless file_name.end_with?('.rb')
      file_name
    end

    # Starts recursive processing from a base file, and adds the required files
    # in results field. The result format is:
    #
    # [["~/foo.rb", [1, 2, 3]], ["~/tmp/bar.rb", [4, 5]], ["~/app.rb", [1]]]
    #
    # The file name returned are in full path. For each file, the line needed to
    # skip is also returned
    #
    # +file_name+ must be a full path
    def process_files(root_file_name)
      file_dir = File.dirname(root_file_name)

      required_files = parse_single_file(root_file_name)
      skip_lines = []

      required_files.each do |lineno, cmd, arg|
        skip_lines <<= lineno
        if cmd == 'require'
          required_file_path = normalize_file_name(arg, file_dir)
          process_files required_file_path if file_not_processed required_file_path
        end
      end

      results << [root_file_name, skip_lines] if file_not_processed root_file_name
    end
  end
end
