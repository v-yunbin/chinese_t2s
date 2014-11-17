require "chinese_t2s/version"

module ChineseT2s
  private
  def self.get_words
    cht_array = []
    hash = {}

    File.read(File.dirname(__FILE__) + '/../vendor/word_t2s.txt').split("\r\n").each do |mapping|
      t, s = mapping.split(',')
      cht_array << t
      hash[t] = s
    end

    [cht_array.join('|'), hash]
  end

  def self.get_phases
    cht_array = []
    hash = {}

    File.read(File.dirname(__FILE__) + '/../vendor/phrase_t2s.txt').split("\r\n").each do |mapping|
      s, t = mapping.split(',')
      cht_array << t
      hash[t] = s
    end

    [cht_array.join('|'), hash]
  end

  REGEX_WORDS_T, WORD_T2S = get_words
  REGEX_PHASES_T, PHASES_T2S = get_phases

  public
  def self.translate(content)
    content.gsub!(/#{REGEX_WORDS_T}/) do |match|
      WORD_T2S[match]
    end

    content.gsub!(/#{REGEX_PHASES_T}/) do |match|
      PHASES_T2S[match]
    end

    content
  end
end

if defined?(::Rails)
  require 'chinese_t2s/middleware'
  require 'chinese_t2s/engine'
end