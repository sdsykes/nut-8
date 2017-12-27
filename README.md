# Shortest Edition solution

## Stephen Sykes

As my go-to language for this kind of text processing, this is a Ruby solution.

When run, the program produces the following result:

    $ ruby shortest.rb
    ---alastalon_salissa---
    Lines: 9225
    Pages: 369
    Line end gaps: 0
    Largest gap: 0

### Solution description

The basic idea is to split the words into "buckets" which contain words of the same length, and then place
them on output lines one by one.

My first attempts focussed on using the biggest words first on each line, then filling the last
bits of space with shorter ones. A common result using this method was about 9364 lines, 375 pages.

I then changed my approach, and started to add words preferentially of the most popular lengths. This allowed
me to drop a few pages off the result, but still there were some gaps at the end of lines.

Then I refined the algorithm to include the possibility to split the remaining space on a line into two equal pieces 
if there are words that would fill it. BINGO! With a bit of tweaking this yielded the goal, zero gaps, 369 pages.

Now I was able to take a few useless bits of code out and hone the algorithm to the minimum that would work perfectly.
It was surprisingly few lines of code, and fast.

Why stop with Alastalon Salissa? I tried some other texts. Project Gutenberg provided me
with some classics: Sherlock Holmes, Moby Dick, Ulysses, Treasure Island, War and Peace, and appropriately 
for the season Dickens's A Christmas Carol.

Use the -a flag to run through all the texts:

    $ ruby shortest.rb -a
    ---alastalon_salissa---
    Lines: 9225
    Pages: 369
    Line end gaps: 0
    Largest gap: 0
    ---adventures_of_sherlock---
    Lines: 1500
    Pages: 60
    Line end gaps: 0
    Largest gap: 0
    ---return_of_sherlock---
    Lines: 1526
    Pages: 62
    Line end gaps: 0
    Largest gap: 0
    ---moby_dick---
    Lines: 3632
    Pages: 146
    Line end gaps: 0
    Largest gap: 0
    ---ulysses---
    ^Cshortest.rb:65:in `block in buckets_empty?': Interrupt
    	from shortest.rb:65:in `each'
    	from shortest.rb:65:in `detect'
    	from shortest.rb:65:in `buckets_empty?'
    	from shortest.rb:104:in `compress'
    	from shortest.rb:139:in `do_book'
    	from shortest.rb:150:in `<main>'

Oh no! It hung on Ulysses. I never liked that book. I investigated the problem, and it became apparent that there was something
fishy in the text. Let's look at the lengths of the words in Ulysses:

    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
    24, 25, 26, 27, 28, 29, 30, 31, 34, 36, 37, 39, 53, 91, 105]

Whoa! 91 and 105 letter words? Not even a Finnish novel can match that. What were these record-breaking
words?

    "—A—sudden—at—the—moment—though—from—lingering—illness—often—previously—expectorated—demise,"
    "Nationalgymnasiummuseumsanatoriumandsuspensoriumsordinaryprivatdocentgeneralhistoryspecialprofessordoctor"

Ah, well, not exactly single words, but for sure there aren't any spaces in there. So the alorithm can't place words
bigger than one line, and gets stuck because the buckets can never empty out. I decided it was acceptable to leave
these "words" out of the compressed version of Ulysses, I think they won't be missed. When preparing the words, we
now skip any that are too long for a line:

    def prepare_buckets
      @buckets = {}
      @words.each do |word|
        next if word.size > 80
        @buckets[word.size] ||= []
        @buckets[word.size] << word
      end
    end

Let's have another go:

    $ ruby shortest.rb -a
    ---alastalon_salissa---
    Lines: 9225
    Pages: 369
    Line end gaps: 0
    Largest gap: 0
    ---adventures_of_sherlock---
    Lines: 1500
    Pages: 60
    Line end gaps: 0
    Largest gap: 0
    ---return_of_sherlock---
    Lines: 1526
    Pages: 62
    Line end gaps: 0
    Largest gap: 0
    ---moby_dick---
    Lines: 3632
    Pages: 146
    Line end gaps: 0
    Largest gap: 0
    ---ulysses---
    Lines: 5133
    Pages: 206
    Line end gaps: 0
    Largest gap: 0
    ---treasure_island---
    Lines: 1165
    Pages: 47
    Line end gaps: 0
    Largest gap: 0
    ---war_and_peace---
    Lines: 4649
    Pages: 186
    Line end gaps: 0
    Largest gap: 0
    ---christmas_carol---
    Lines: 740
    Pages: 30
    Line end gaps: 0
    Largest gap: 0

Success! Eight books compressed to the max. Note that some texts will inevitably not get perfect results, but
I'm quite satisfied with this performance.

The output files, if you want to read them, have .shortversion appended,
e.g. alastalon_salissa.txt.shortversion

### Quotes

*"Christmas. wonderful legatee, shrivelled clutching, deadest burial Idea, Last one"* -- A timely reminder from Charles Dickens, A Christmas Carol (compressed)

*"For ye sidetable, reassured keyholes bright, retreat."* -- Advice from Robert Louis Stevenson, Treasure Island (compressed)

*"Bolkónski” certain, festive practicing deplorable."* -- Warning from Leo Tolstoy, War and Peace (compressed)

*"Monkwords, marybeads jabber on their girdles"* -- Total nonsense from James Joyce, Ulysses (original)

### Thanks

Thanks to Wunderdog once again for [the puzzle](https://wunder.dog/the-shortest-edition)!
