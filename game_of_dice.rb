class PlayGame

  DICE_NUMBERS = (1..6).to_a
  WINNER = :WINNER
  IN_GAME = :IN_GAME
  YET_TO_START = :YET_TO_START
  SKIP_NEXT_TURN = :SKIP_NEXT_TURN
  GAME_MESSAGES = {
    received_6: 'You have rolled 6!. You get one more chance.',
    received_1: 'You have rolled 1!. Beware, if you receive 1 again, then your next chance will be skipped.',
    chance_skipped: 'Your last rolled Dice received 1, so skipping this chance'
  }

  def initialize(total_players, points_accumulate)
    @total_players = total_players
    @points_accumulate = points_accumulate
    @playing_players = (1..total_players).to_a
    @won_players = []
    init_players_score_table
  end

  def start
    show_welcome_message
    start_player = next_player
    while !all_players_won? do
      @won_players = []
      @playing_players[start_player..-1].each do |player_number|
        if @points_score_table[player_number.to_s][:status] == SKIP_NEXT_TURN
          @points_score_table[player_number.to_s][:status] = IN_GAME
          next
        end
        @points_score_table[player_number.to_s][:status] = IN_GAME
        add_to_player_score player_number, rolled_dice_number if player_rolled_a_dice? player_number
        print_players_score_table
      end
      reset_remaining_players
      start_player = 0 if start_player != 0
    end
  end

  private

  def show_welcome_message
    puts "Total Players: #{@total_players}"
    puts "Points To Accumulate: #{@points_accumulate}"
    print_players_score_table
  end

  def add_to_player_score player_number, dice_number
    if last_dice_was_one? player_number, dice_number
      skip_next_turn player_number
      return
    end
    @points_score_table[player_number.to_s][:score] += dice_number
    @points_score_table[player_number.to_s][:last_dice_number] = dice_number
    if @points_score_table[player_number.to_s][:score] >= @points_accumulate
      player_won player_number
      @playing_players.delete player_number
      return
    end
    unless GAME_MESSAGES["received_#{dice_number}".to_sym].nil?
      print_game_message dice_number
      play_again player_number
    end
  end

  def last_dice_was_one? player_number, current_dice
    @points_score_table[player_number.to_s][:last_dice_number] == current_dice
  end

  def rolled_dice_number
    dice_number = DICE_NUMBERS.sample
    puts "Dice Rolled, Received: #{dice_number}"
    dice_number
  end

  def play_again player_number
    add_to_player_score player_number, rolled_dice_number if player_rolled_a_dice? player_number
  end

  def skip_next_turn player_number
    @points_score_table[player_number.to_s][:status] = SKIP_NEXT_TURN
  end

  def next_player
    @playing_players.sample
  end

  def all_players_won?
    @playing_players.empty?
  end

  def player_rolled_a_dice? player_number
    puts "Player-#{player_number} it's your turn (press 'r' to roll the dice)"
    begin
      user_input = STDIN.gets.chomp
      puts "press 'r'" if user_input != 'r'
    end while(user_input != 'r')
    true
  end

  def print_players_score_table
    puts '_________________________________________________________________________________________________'
    puts "|\t Player Number \t|\t Score / Acumulate Points \t\t|\t Status \t|"
    puts '|-----------------------+-----------------------------------------------+-----------------------|'
    1.upto(@total_players) do |player_number|
      puts "|\t\t#{player_number} \t|\t\t #{@points_score_table[player_number.to_s][:score]}/#{@points_accumulate} \t\t\t\t|\t #{@points_score_table[player_number.to_s][:status]} \t|"
      puts '|-----------------------+-----------------------------------------------+-----------------------|'
    end
    puts
  end

  def print_game_message dice_number
    puts GAME_MESSAGES["received_#{dice_number}".to_sym]
  end

  def player_won player_number
    puts "Player #{player_number} Won! Congraluations!!"
    @points_score_table[player_number.to_s][:status] = WINNER
    @won_players.push player_number
  end

  def reset_remaining_players
    @playing_players -= @won_players
  end

  def init_players_score_table
    @points_score_table = Hash.new
    1.upto(@total_players) do |player_number|
      @points_score_table[player_number.to_s] = {
        score: 0,
        last_dice_number: 0,
        status: YET_TO_START
      }
    end
  end
end


total_players = ARGV[0].to_i
points_accumulate = ARGV[1].to_i
raise 'Players should be more than 0' if total_players <= 0
raise 'Points of Accumulate should be positive number' if points_accumulate < 0

PlayGame.new(total_players, points_accumulate).start


# First Paramerter is total players, and second is points accumulate
