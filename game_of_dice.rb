class PlayGame

  DICE_NUMBERS = (1..6).to_a
  WINNER = :WINNER
  IN_GAME = :IN_GAME
  YET_TO_START = :YET_TO_START
  SKIP_NEXT_TURN = :SKIP_NEXT_TURN
  TILL_END_PLAYER = -1
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
    @last_rank = 0
    init_players_score_table
  end

  def start
    show_welcome_message
    start_player = next_player
    while !all_players_won? do
      @playing_players[start_player..TILL_END_PLAYER].each do |player_number|
        if @points_score_table[player_number.to_s][:status] == SKIP_NEXT_TURN
          allow_next_turn player_number
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
    puts '*********************************************************************'
    puts '*               + + + Welcome to Rolling Dice Game + + +            *'
    puts '*********************************************************************'
    puts "Total Players: \t#{@total_players}"
    puts "Points To Accumulate: \t#{@points_accumulate}"
    puts 'Rules:'
    puts "1: If you get 6 on rolled dice, you will get a bonus chance!"
    puts "2: If you get consecutive 1 on rolled dice, then your next chance will be skipped. Sorry! Rule is Rule :-D"
    puts '*********************************************************************'
    puts "*\t\t\t+ + + Let\'s Begin + + +\t\t\t    *"
    puts '*********************************************************************'
    print_players_score_table
  end

  def add_to_player_score player_number, dice_number
    @points_score_table[player_number.to_s][:score] += dice_number
    if @points_score_table[player_number.to_s][:score] >= @points_accumulate
      player_won player_number
      @playing_players.delete player_number
      return
    end
    if last_dice_was_one? player_number, dice_number
      skip_next_turn_of player_number
      return
    end
    @points_score_table[player_number.to_s][:last_dice_number] = dice_number
    unless GAME_MESSAGES["received_#{dice_number}".to_sym].nil? && dice_number != 1
      print_game_message dice_number
      play_again player_number
    end
  end

  def last_dice_was_one? player_number, current_dice
    current_dice == 1 && @points_score_table[player_number.to_s][:last_dice_number] == 1
  end

  def rolled_dice_number
    dice_number = DICE_NUMBERS.sample
    puts "Dice Rolled, Received: #{dice_number}"
    dice_number
  end

  def play_again player_number
    print_players_score_table
    add_to_player_score player_number, rolled_dice_number if player_rolled_a_dice? player_number
  end

  def skip_next_turn_of player_number
    @points_score_table[player_number.to_s][:status] = SKIP_NEXT_TURN
  end

  def allow_next_turn player_number
    puts "Player-#{player_number}, #{GAME_MESSAGES[:chance_skipped]}"
    @points_score_table[player_number.to_s][:status] = IN_GAME
  end

  def next_player
    @playing_players.sample
  end

  def all_players_won?
    @playing_players.empty?
  end

  def player_rolled_a_dice? player_number
    print "Player-#{player_number} it's your turn (press 'r' to roll the dice): "
    begin
      user_input = STDIN.gets.chomp
      print "press 'r': " if user_input != 'r'
    end while(user_input != 'r')
    true
  end

  def print_players_score_table
    print_table_column_headers
    1.upto(@total_players) do |player_number|
      print_player_score_table_row player_number
    end
    puts
  end

  def print_game_message dice_number
    puts GAME_MESSAGES["received_#{dice_number}".to_sym]
  end

  def player_won player_number
    puts "Player #{player_number} Won! Congraluations!!"
    @points_score_table[player_number.to_s][:status] = WINNER
    @points_score_table[player_number.to_s][:rank] = @last_rank+1
    @last_rank += 1
    @won_players.push player_number
  end

  def reset_remaining_players
    @playing_players -= @won_players
    @won_players = []
  end

  def print_player_score_table_row player_number
    row = "|\t\t#{player_number} \t"
    row += "|\t\t #{@points_score_table[player_number.to_s][:score]}/#{@points_accumulate} \t\t\t\t"
    row += "|\t #{@points_score_table[player_number.to_s][:status]} \t"
    row += "|\t #{@points_score_table[player_number.to_s][:rank]} \t|"
    puts row
    print_table_row_separator
  end

  def print_table_row_separator
    puts '|-----------------------+-----------------------------------------------+-----------------------|---------------|'
  end

  def print_table_column_headers
    print_table_row_separator
    puts "|\t Player Number \t|\t Score / Acumulate Points \t\t|\t Status \t|\tRank\t|"
    print_table_row_separator
  end

  def init_players_score_table
    @points_score_table = Hash.new
    1.upto(@total_players) do |player_number|
      @points_score_table[player_number.to_s] = {
        score: 0,
        last_dice_number: 0,
        status: YET_TO_START,
        rank: 0
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
