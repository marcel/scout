module Scout
  class TransactionTracker
    LAST_SEEN_TRANSACTION_ID_FILE = File.join(File.expand_path(File.dirname(__FILE__)), "../../config", "last_seen_transaction_ids.yml") unless defined? LAST_SEEN_TRANSACTION_ID_FILE
    
    class << self
      def load_last_seen_transaction_ids
        YAML.load_file(LAST_SEEN_TRANSACTION_ID_FILE) 
      rescue Errno::ENOENT => e
        {Scout::Resource::LEAGUE_KEY => 105}
      end
      
      def save_last_seen_transaction_ids(updated_ids)
        File.open(LAST_SEEN_TRANSACTION_ID_FILE, "w") do |file|
          file.write updated_ids.to_yaml
        end
      end
    end
    
    attr_reader :league_key, :last_transaction_id
    
    def initialize(league_key, last_transaction_id)
      @league_key = league_key
      @last_transaction_id = last_transaction_id
    end
    
    def update
      transactions.each do |transaction|
        message = "[#{Resource::LEAGUES[league_key]}] " + transaction.message.text
        puts message
        # FIXME UNCOMMENT
        SMS.send_to_me(message)
        Email.send_to_me(message, message)
      end
      
      max_transaction_id
    rescue Exception => e
      summary = "[ALERT] Exception TransactionTracker: #{e.message}"
      details = "Exception! #{e.message}: #{e.backtrace.join("\n")}"
      puts "\n#{details}\n"
      # FIXME UNCOMMENT
      SMS.send_to_me(summary)
      Email.send_to_me(summary, details)
    end
    
    # FIXME UNCOMMENT
    def transactions
      @transactions ||= client.transactions(league_key).select { |t|
        t.transaction_id > last_transaction_id
      }.map {|t|
        TransactionUpdate.new(t)
      }.reverse
    end
    
    # FIXME COMMENT
    # def transactions
    #   YAML.load_file("/Users/marcel/workspace/projects/scout/transactions-2015.yml").map {|t| TransactionUpdate.new(t) }.reverse
    # end
    
    def client
      @client ||= Scout::Client.new
    end
    
    def max_transaction_id
      transactions.map(&:transaction).map(&:transaction_id).max
    end
    
    class TransactionUpdate      
      attr_reader :transaction
      
      def initialize(transaction)
        @transaction = transaction
      end
      
      def message
        @message ||= begin
          case transaction.type
          when "add/drop"
            AddDropMessage.new(transaction)
          when "add"
            AddMessage.new(transaction)
          when "drop"
            DropMessage.new(transaction)
          when "trade"
            TradeMessage.new(transaction)
          end
        end
      end
      
      class Message # N.B. Abstract
        attr_reader :transaction
        
        def initialize(transaction)
          @transaction = transaction
        end
        
        def faab_bid
          transaction.faab_bid rescue nil
        end
        
        def players
          transaction.players
        end
        
        def player_name(player)
          "#{player.display_position} #{player.name.full}"
        end
        
        def text
          raise "`text` should be defined by subclass"
        end
      end
      
      class AddDropMessage < Message
        def add
          @add ||= players.find {|p| p.transaction_data.type == "add" }
        end
        
        def drop
          @drop ||= players.find {|p| p.transaction_data.type == "drop" }
        end
        
        def was_free_agent?
          add.transaction_data.source_type == "freeagents"
        end
        
        def add_text
          manager = add.transaction_data.destination_team_name
          
          if was_free_agent?
            "#{manager} ADDED FA #{player_name(add)}"
          else
            base_waiver_message = "#{manager} ADDED #{player_name(add)} from waivers"
            if bid_amount = faab_bid
              "#{base_waiver_message} for $#{faab_bid}"
            else
              base_waiver_message
            end
          end
        end
        
        def drop_text
          "DROPPED #{player_name(drop)}"
        end
        
        def text
          [add_text, drop_text].join("; ")
        end
      end
      
      class AddMessage < Message
        def text
          AddDropMessage.new(transaction).add_text
        end
      end
      
      class DropMessage < Message 
        def text
          dropped_player = players.first
          data           = dropped_player.transaction_data
          
          "#{data.source_team_name} DROPPED #{player_name(dropped_player)}"
        end
      end
      
      class TradeMessage < Message
        def text
          team_a = transaction.trader_team_name
          team_b = transaction.tradee_team_name
          
          team_a_traded, team_a_received = *transaction.players.partition {|player| player.transaction_data.source_team_name == team_a }
          display_teams = ->(player_list) { player_list.map {|p| player_name(p) }.to_sentence  }
          
          "#{team_a} TRADED #{display_teams.call(team_a_traded)} to #{team_b} IN EXCHANGE FOR #{display_teams.call(team_a_received)}"
        end
      end
    end
  end
end

if __FILE__ == $0  
  last_seen_transaction_ids = Scout::TransactionTracker.load_last_seen_transaction_ids
  last_seen_transaction_ids.each do |league_key, last_seen_transaction_id|  
    tracker = Scout::TransactionTracker.new(league_key, last_seen_transaction_id)

    if new_last_seen_transaction_id = tracker.update
      puts "- Updated - #{Time.now}"
      last_seen_transaction_ids[league_key] = new_last_seen_transaction_id
      # FIXME UNCOMMENT
      Scout::TransactionTracker.save_last_seen_transaction_ids(last_seen_transaction_ids)
    end
  end
end