class HolidaysController < ApplicationController
  def index
    @holidays = Holiday.where("(start_date >= :year_start AND start_date <= :year_end) OR (end_date >= :year_start AND end_date <= :year_end)",
                              year_start: Date.today.at_beginning_of_year, year_end: Date.today.at_end_of_year)
  end
end
