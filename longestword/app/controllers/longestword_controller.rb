require 'open-uri'
require 'json'

class LongestwordController < ApplicationController

  # def initialize

  # end

  def game
    @grid = (0...9).map { ('a'..'z').to_a[rand(26)].capitalize }
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @your_word = params[:your_word]
    @grid = params[:get_grid].split(" ")
    @start_time = DateTime.parse(params[:start_time])
    @result = run_game(@your_word, @grid, @start_time, @end_time)
  end

  def is_in_the_grid(grid, attempt)
    duplicate_grid = grid.map(&:downcase)
    attempt.downcase.split('').each do |attempt_letter|
      if duplicate_grid.include?(attempt_letter)
        duplicate_grid.delete(attempt_letter)
      else
        return false
      end
    end
    return true
  end


  def run_game(attempt, grid, start_time, end_time)

    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"

    translated_attempt = ""
    message_result = ""
    score_result = 1

    open(api_url) do |stream|
      word = JSON.parse(stream.read)
      if !is_in_the_grid(grid, attempt)
        translated_attempt = nil
        score_result = 0
        message_result = "not in the grid"
      else
        if word['term0']
          translated_attempt = word['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
          score_result = attempt.length/(end_time - start_time)
          message_result = "well done"
        else
          translated_attempt = nil
          score_result = 0
          message_result = "not an english word"
        end
      end
    end

    result = {
      time: end_time - start_time,
      translation: translated_attempt,
      score: score_result,
      message: message_result
    }

    result

  end

end
