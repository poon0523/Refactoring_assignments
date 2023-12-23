class Club < ApplicationRecord
  has_one_attached :logo

  has_many :home_matches, class_name: "Match", foreign_key: "home_team_id"
  has_many :away_matches, class_name: "Match", foreign_key: "away_team_id"
  has_many :players
  belongs_to :league

  def matches
    Match.where("home_team_id = ? OR away_team_id = ?", self.id, self.id)
  end

  def matches_on(year = nil)
    return nil unless year

    matches.where(kicked_off_at: Date.new(year, 1, 1).in_time_zone.all_year)
  end

  def won?(match)
    match.winner == self
  end

  def lost?(match)
    match.loser == self
  end

  def draw?(match)
    match.draw?
  end

  def win_on(year)
    result_case = "win"
    self.matches_result(year,result_case)
  end

  def lost_on(year)
    result_case = "lost"
    self.matches_result(year,result_case)
  end

  def draw_on(year)
    result_case = "draw"
    self.matches_result(year,result_case)
  end

  # def win_on(year)
  #   year = Date.new(year, 1, 1)
  #   count = 0
  #   matches.where(kicked_off_at: year.all_year).each do |match|
  #     count += 1 if won?(match)
  #   end
  #   count
  # end

  # def lost_on(year)
  #   year = Date.new(year, 1, 1)
  #   count = 0
  #   matches.where(kicked_off_at: year.all_year).each do |match|
  #     count += 1 if lost?(match)
  #   end
  #   count
  # end

  # def draw_on(year)
  #   year = Date.new(year, 1, 1)
  #   count = 0
  #   matches.where(kicked_off_at: year.all_year).each do |match|
  #     count += 1 if draw?(match)
  #   end
  #   count
  # end

  # リファクタリング2:def homebaseロジックはckub_decoratorに移動
  # def homebase
  #   "#{hometown}, #{country}"
  # end

  #リファクタリング1：app/controllers/clubs_controller.rbのshowアクションのロジックをモデルに移動
  def players_average_age
    (self.players.sum(&:age) / self.players.length).to_f
  end

  private

  def matches_result(year,result_case)
    year = Date.new(year, 1, 1)
    count = 0
    matches_on_this_year = matches.where(kicked_off_at: year.all_year)

    case result_case
    when "win"
      matches_on_this_year.each{ |match| count += 1 if won?(match)}
    when "lost"
      matches_on_this_year.each{ |match| count += 1 if lost?(match)}
    when "draw"
      matches_on_this_year.each{ |match| count += 1 if draw?(match)}
    end
    count
  end

end
