module MrubyMix

  # Processes a single file and returned all required items with line numbers
  # and item name in the following format:
  #
  #   [[2, "require", "foo"], [3, "require", "bar"]]
  #
  def self.parse_single_file(file_name)
    results = []
    File.open(file_name, "r") do |f|
      f.each do |l|
        words = l.split(' ').select {|w| !w.empty? }
        if (words.length == 3) &&
            (words[0] == '#=')
          results <<= [f.lineno, words[1], words[2]]
        end
      end
    end
    results
  end

  # Starts recursive processing from a base file, and return an array of files
  # needed to add(including it self). The result format is:
  #
  # [["~/foo.rb", [1, 2, 3]], ["~/tmp/bar.rb", [4, 5]], ["~/app.rb", [1]]]
  #
  # The file name returned are in full path. For each file, the line needed to
  # skip is also returned
  def self.process(file_name)
    file_name <<= '.rb' unless file_name.end_with?('.rb')
    file_name = File.expand_path(file_name)
    file_dir = File.dirname(file_name)

    results = []

    required_files = parse_single_file(file_name)
    skip_lines = []

    required_files.each do |lineno, cmd, arg|
      skip_lines <<= lineno
      if cmd == 'require'
        process(File.join(file_dir, arg)).each do |r|
          if !results.index(r)
            results << r
          end
        end
      end
    end

    root_item = [file_name, skip_lines]
    if !results.index(root_item)
      results << root_item
    end

    results
  end

  # mix all source files trackable from the root file
  def self.mix(root_file_name, dst_file_name)
    results = process(root_file_name)

    File.open(dst_file_name, "w") do |o_f|
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
end
