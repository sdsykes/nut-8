# Shortest Edition
# Stephen Sykes, December 2017
# Pack the words of a text into 80 character lines efficiently.

class ShortestEdition
  def initialize(filename)
    @lines = []
    prepare_words(filename)
    prepare_buckets
  end

  # Get words from a file.
  def prepare_words(filename)
    @words = []
    File.readlines(filename).each do |line|
      line.split.each {|word| @words << word}
    end
  end
  
  # Place words in buckets according to their length.
  def prepare_buckets
    @buckets = {}
    @words.each do |word|
      next if word.size > 80
      @buckets[word.size] ||= []
      @buckets[word.size] << word
    end
  end

  # The line being constructed.
  def current_line
    @lines[@current_index]
  end

  # Remaining space on the current line.
  def remaining
    80 - current_line.size
  end

  # Add a word of size to the current line, unless it won't fit.
  # Return true if the append succeeded.
  def append_word(size)
    return false unless remaining > size
    w = @buckets[size].pop
    @lines[@current_index] += @sep + w
    @sep = " "
    return true
  end

  # Is there a word left in the size bucket?
  def have_size?(size)
    @buckets[size] && @buckets[size].size != 0
  end

  # What bucket has the most words left in it?
  # Prefer longer words when equal numbers are left.
  def largest_sized_bucket
    keys = @buckets.keys.sort
    keys.reverse.inject(keys[0]) {|max, k| @buckets[max].size < @buckets[k].size ? k : max}
  end
  
  # When the buckets are empty, the job is done.
  def buckets_empty?
    !@buckets.keys.detect {|size| @buckets[size].size > 0}
  end

  # This is the meat of the algorithm. It's entirity
  # is expressed in the two short methods below.
  
  # Simply add the suggested sized word to the line, and then try
  # to add another word based on the remaining space, or our
  # most numerous remaining size.
  def add_words_starting_size(size)
    return if remaining <= 1 || buckets_empty?

    if !have_size?(size)
      try_another_size(size)
    else
      append_word(size)
      add_words_starting_size([remaining - 1, largest_sized_bucket].min)
    end
  end

  # When the requested size is not available, try to split the
  # remaining space in two, and add two words to fill, or if
  # that won't work then add from the most numerous bucket
  # and then try to fill the space we have left. Finally, if no word
  # could be appended, try with one less character than size.
  def try_another_size(size)
    half_size = remaining / 2 - 1
    append_size = have_size?(half_size) ? half_size : largest_sized_bucket

    if append_word(append_size)
      add_words_starting_size(remaining - 1)
    elsif size > 1
      add_words_starting_size(size - 1)
    end
  end

  # Fill the lines from the buckets.
  def compress
    @current_index = 0
    while !buckets_empty?
      @sep = ""
      @lines[@current_index] = ""
      add_words_starting_size(0)
      @current_index += 1
    end
  end

  # Give some data about the result.
  def report
    puts "Lines: #{@lines.size}"
    puts "Pages: #{(@lines.size + 24) / 25}"

    gaps = 0
    biggest = 0
    @lines[0..-2].each do |l|
      gap = 80 - l.size
      gaps += gap
      biggest = [biggest, gap].max
    end
    
    puts "Line end gaps: #{gaps}"
    puts "Largest gap: #{biggest}"
  end
  
  # Write the lines to a file.
  def print_book(outfile)
    out = File.open(outfile, "w")
    @lines.each {|line| out.puts(line)}
  end
end

def do_book(filename)
  puts "---#{filename.gsub(/.txt$/, "")}---"
  wundernut = ShortestEdition.new(filename)
  wundernut.compress
  wundernut.print_book(filename.gsub(/.txt$/, ".compressed.txt"))
  wundernut.report
end

do_book("alastalon_salissa.txt")

if ARGV[0] == "-a"
  do_book("adventures_of_sherlock.txt")
  do_book("return_of_sherlock.txt")
  do_book("moby_dick.txt")
  do_book("ulysses.txt")
  do_book("treasure_island.txt")
  do_book("war_and_peace.txt")
  do_book("christmas_carol.txt")
end
