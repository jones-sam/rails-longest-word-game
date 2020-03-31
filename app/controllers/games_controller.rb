# frozen_string_literal: true

class GamesController < ApplicationController
  def new
    @start_time = Time.now
    @letters = []
    array_of_letters = ('A'..'Z').to_a
    grid_size = 10
    grid_size.times do
      @letters << array_of_letters[rand(26)]
    end
  end

  def score
    @word = params[:word]
    letters = params[:letters].split
    start_time = params[:start_time]
    time_passed = (Time.now - start_time.to_time)
    @time_passed = time_passed.round

    response = HTTParty.get("https://wagon-dictionary.herokuapp.com/#{@word}")
    word_hash = JSON.parse(response.body)

    @message = "#{@word} is not a valid word!" if word_hash['found'] == false
    @message = 'You did not input a word' if @word.empty?

    chars_in_grid = true

    @word.upcase.split('').each do |letter|
      if letters.include?(letter)
        letters.delete_at(letters.index(letter))
      else
        @message = 'You included a character that was not avaliable'
        chars_in_grid = false
      end
    end

    if word_hash['found'] == true && chars_in_grid == true
      score = [(1000 * word_hash['length'] - (time_passed * 100)).round, 0].max
      @message = "Congrats! Your word \"#{@word}\" gets you a score of #{score}"
    end
  end
end
