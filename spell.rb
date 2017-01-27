require 'rubygems'
require 'sinatra'

def words(text)
  text.downcase.scan(/[a-z]+/)
end

def train(features)
  model = Hash.new(1)
  features.each {|f| model[f] += 1 }
  return model
end

def edits1(word)
  n = word.length

  deletes = (0...n).collect  { |i| word[0...i] + word[i+1..-1] }
  transposes = (0...n-1).collect { |i| word[0...i]+word[i+1,1]+word[i,1]+word[i+2..-1] }
  replaces = (0...n).collect   { |i| (0...26).collect { |l| word[0...i] + LETTERS[l].chr + word[i+1..-1] } }
  inserts = (0...n+1).collect { |i| (0...26).collect { |l| word[0...i] + LETTERS[l].chr + word[i...-1] } }

  (deletes | transposes | replaces | inserts).flatten
end

def known_edits2(word)
  edits1(word).collect { |e| edits1(e).select { |e2| NWORDS.has_key?(e2) } }
end

def known(words)
  words.select { |w| NWORDS.has_key?(w)}
end

def correct(word)
  (known([word]) | known(edits1(word)) | known_edits2(word) | [word]).max {|a,b| NWORDS[a] <=> NWORDS[b] }.first
end

NWORDS = train(words(File.new('/usr/share/dict/words').read))
LETTERS = ("a".."z").to_a.join


get '/:word' do
  correct(params[:word])
end
