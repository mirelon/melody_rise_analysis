# Morfoznacky: https://is.muni.cz/el/1421/jaro2006/CJBB105/um/popis_znacek.pdf
class Sentence
  attr_accessor :words

  # Initialize words with pairs [String, Array[Word]]
  # First:
  #   word.word to keep uppercase for names and titles
  #   sentence_part as fallback
  # Second:
  #   multiple possible Words (with same word), e.g. "dám" vs. "dám"
  def initialize(sentence)
    @words = sentence.split.map do |sentence_part|
      possible_words = Word.where(word: sentence_part)
      [possible_words.present? ? possible_words.sample.word : sentence_part, possible_words]
    end
  end

  # @return Array of Sentence
  def self.parse(text)
    raw_sentences = text.split(/[\.,]/).map(&:strip)
    puts "#{raw_sentences.size} raw sentences"
    raw_sentences.map{|sentence| print '.'; Sentence.new(sentence)}
  end

  def index_prisudku
    @words.find_index{|w| w.second.any?{|ww| ww.tag.start_with?('V')}}
  end

  def index_podmetu
    @words.find_index{|w| w.second.any?{|ww| ww.tag.start_with?('S')}}
  end

  def otazka
    if index_podmetu and index_prisudku and index_podmetu < index_prisudku
      ([@words[index_prisudku]] + @words[0..(index_prisudku - 1)] + @words[(index_prisudku + 1)..-1]).select do |w|
        w.second.any?{|ww| ww.tag != 'T'}
      end.map(&:first).join(' ').upcase_first + '?'
    else
      StandardError.new "Chýba podmet alebo prísudok: #{@words}"
    end
  end
end
