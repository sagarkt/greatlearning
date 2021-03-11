class PlayGame

  WINNER = :WINNER
  PLAYING = :PLAYING
  YET_TO_START = :YET_TO_START
  DICE_NUMBERS = (1..6).to_a

  def initialize(total_players, points_accumulate)
    @total_players = total_players
    @points_accumulate = points_accumulate
    @playing_players = (1..total_players).to_a
    init_players_score_table
  end

  def start
    while !all_players_won? do
      @playing_players[next_player..-1].each do |player_number|
      end
    end
  end

  private

  def roll_a_dice
    DICE_NUMBERS.sample
  end

  def next_player
    @playing_players.sample
  end

  def all_players_won?
    @playing_players.empty?
  end

  def init_players_score_table
    @points_score_table = Hash.new
    1.upto(@total_players) do |player_number|
      @points_score_table[player_number.to_s] = {
        score: 0,
        status: YET_TO_START
      }
    end
  end
end


total_players = ARGV[0]
points_accumulate = ARGV[1]
raise 'Players should be more than 0' if total_players.to_i <= 0
raise 'Points of Accumulate should be positive number' if points_accumulate.to_i < 0

PlayGame.new(total_players, points_accumulate).start


# First Paramerter is total players, and second is points accumulate
