class CreateStadiums < ActiveRecord::Migration
  def change
    create_table :stadiums do |t|
      t.string :zip
      t.string :team_abbr
      t.string :armchair_analysis_team_name
      t.string :name

      t.timestamps
    end
    add_index :stadiums, :team_abbr
    add_index :stadiums, :armchair_analysis_team_name

    stadiums = [
      {:name=>"Arrowhead Stadium", :zip=>"64129", :armchair_analysis_team_name=>"KC", :team_abbr=>"KC"},
      {:name=>"AT&T Stadium", :zip=>"94107", :armchair_analysis_team_name=>"DAL", :team_abbr=>"Dal"},
      {:name=>"Bank of America Stadium", :zip=>"28202", :armchair_analysis_team_name=>"CAR", :team_abbr=>"Car"},
      {:name=>"Candlestick Park", :zip=>"94124", :armchair_analysis_team_name=>"SF", :team_abbr=>"SF"},
      {:name=>"CenturyLink Field", :zip=>"98134", :armchair_analysis_team_name=>"SEA", :team_abbr=>"Sea"},
      {:name=>"Edward Jones Dome", :zip=>"63101", :armchair_analysis_team_name=>"STL", :team_abbr=>"StL"},
      {:name=>"Everbank Field", :zip=>"32202", :armchair_analysis_team_name=>"JAC", :team_abbr=>"Jax"},
      {:name=>"FedEx Field", :zip=>"20785", :armchair_analysis_team_name=>"WAS", :team_abbr=>"Was"},
      {:name=>"FirstEnergy Stadium", :zip=>"44114", :armchair_analysis_team_name=>"CLE", :team_abbr=>"Cle"},
      {:name=>"Ford Field", :zip=>"48226", :armchair_analysis_team_name=>"DET", :team_abbr=>"Det"},
      {:name=>"Georgia Dome", :zip=>"30313", :armchair_analysis_team_name=>"ATL", :team_abbr=>"Atl"},
      {:name=>"Gillette Stadium", :zip=>"02035", :armchair_analysis_team_name=>"NE", :team_abbr=>"NE"},
      {:name=>"Heinz Field", :zip=>"15212", :armchair_analysis_team_name=>"PIT", :team_abbr=>"Pit"},
      {:name=>"Lambeau Field", :zip=>"54304", :armchair_analysis_team_name=>"GB", :team_abbr=>"GB"},
      {:name=>"Lincoln Financial Field", :zip=>"19147", :armchair_analysis_team_name=>"PHI", :team_abbr=>"Phi"},
      {:name=>"LP Field", :zip=>"37213", :armchair_analysis_team_name=>"TEN", :team_abbr=>"Ten"},
      {:name=>"Lucas Oil Stadium", :zip=>"46225", :armchair_analysis_team_name=>"IND", :team_abbr=>"Ind"},
      {:name=>"M&T Bank Stadium", :zip=>"21230", :armchair_analysis_team_name=>"BAL", :team_abbr=>"Bal"},
      {:name=>"Mall of America Field at HHH Metrodome", :zip=>"55415", :armchair_analysis_team_name=>"MIN", :team_abbr=>"Min"},
      {:name=>"Mercedes-Benz Superdome", :zip=>"70112", :armchair_analysis_team_name=>"NO", :team_abbr=>"NO"},
      {:name=>"MetLife Stadium", :zip=>"07073", :armchair_analysis_team_name=>"NYG", :team_abbr=>"NYG"},
      {:name=>"MetLife Stadium", :zip=>"07073", :armchair_analysis_team_name=>"NYJ", :team_abbr=>"NYJ"},
      {:name=>"O.Co Coliseum", :zip=>"94621", :armchair_analysis_team_name=>"OAK", :team_abbr=>"Oak"},
      {:name=>"Paul Brown Stadium", :zip=>"45202", :armchair_analysis_team_name=>"CIN", :team_abbr=>"Cin"},
      {:name=>"Qualcomm Stadium", :zip=>"92108", :armchair_analysis_team_name=>"SD", :team_abbr=>"SD"},
      {:name=>"Ralph Wilson Stadium", :zip=>"14127", :armchair_analysis_team_name=>"BUF", :team_abbr=>"Buf"},
      {:name=>"Raymond James Stadium", :zip=>"33607", :armchair_analysis_team_name=>"TB", :team_abbr=>"TB"},
      {:name=>"Reliant Stadium", :zip=>"77054", :armchair_analysis_team_name=>"HOU", :team_abbr=>"Hou"},
      {:name=>"Soldier Field", :zip=>"60605", :armchair_analysis_team_name=>"CHI", :team_abbr=>"Chi"},
      {:name=>"Sports Authority Field at Mile High", :zip=>"80204", :armchair_analysis_team_name=>"DEN", :team_abbr=>"Den"},
      {:name=>"Sun Life Stadium", :zip=>"33056", :armchair_analysis_team_name=>"MIA", :team_abbr=>"Mia"},
      {:name=>"University of Phoenix Stadium", :zip=>"85305", :armchair_analysis_team_name=>"ARI", :team_abbr=>"Ari"}
    ]

    stadiums.each do |stadium|
      Stadium.create(stadium)
    end
  end
end
