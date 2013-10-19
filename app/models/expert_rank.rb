class ExpertRank < ActiveRecord::Base
  belongs_to :player, {
    foreign_key: :yahoo_player_key,
    primary_key: :yahoo_key,
    inverse_of: :expert_ranks
  }

  def cached_player
    Scout.cache.fetch([Player.name, cache_key]) { player }
  end

  def ranked_in_previous_week?
    week != 1 && cached_player.cached_expert_ranks.any? {|r| r.week == week - 1}
  end

  def previous_week
    cached_player.cached_expert_ranks.detect {|r| r.week == week - 1}
  end

  class << self
    include Scout::ImportLogging

    # Policy: Update existing for the week
    def import(week = GameWeek.current.week, positions = %w[quarterback wide-receiver running-back tight-end defense-special-teams kicker])
      import_log "Started week #{week} import at #{Time.now}"
      if SLUGS.values.first.size < week
        import_log "No slugs for week #{week}"
        return
      end
      new_records     = 0
      updated_records = 0
      ranks_to_save = Array(positions).flatten.shuffle.map do |position|
        import_log "loading rankings for #{position}"
        user_agent = ExpertRank::ImporterUserAgents.shuffle.first
        page_id = SLUGS[position][week - 1]

        h = open("http://sports.yahoo.com/news/week-#{week}-rankings--#{position}-#{page_id}.html", 'User-Agent'=> user_agent).read
        week_returned = h[/More Week (\d+) Rankings/, 1].to_i

        if week_returned != week
          import_log "WARNING: Requested week #{week} but got #{week_returned}. Skipping."
          next []
        end

        doc = Nokogiri::HTML(h)
        t = doc.at('.body table')
        rows = t.css('tr')
        import_log "rows for #{position}: #{rows.size}"
        player_rows = rows[2..-1]

        # TODO make sure we extract values for at least 30 or so rows to
        # warn against markup format changes that might cause this to silently do
        # nothing without failing.
        player_rows.map do |row|
          columns = row.css('td')[0...-1] # Skip the last column which is a link
          columns.first.text =~ /^(\d+)\. (.+)$/
          overall_rank = $1.to_i
          player_name = $2

          if position == 'defense-special-teams'
            team_name = player_name.split[0..-2].join(' ')
            if team = Player.where(full_name: team_name, team_full_name: player_name).take
              player_key = team.yahoo_key
            else
              import_log "couldn't find team named: #{team_name}. Skipping."
              next
            end
          else
            player_id = columns.first.at('a').attributes['href'].value[%r[players/(\d+)], 1]
            player_key = "314.p.#{player_id}"
          end

          rank_values = {yahoo_player_key: player_key, week: week, overall_rank: overall_rank, position_type: position}
          individual_ranks = columns[1..-1].map(&:text).map {|rank| rank == '-' ? 0 : rank.to_i }
          ranks_by_expert = Hash[
            *individual_ranks.each_with_index.map do |rank, index|
              [:"expert_#{index+1}_rank", individual_ranks[index]]
            end.flatten
          ]

          rank_values.update(ranks_by_expert)
          if existing_expert_rank = ExpertRank.where(week: week, yahoo_player_key: player_key).first
              existing_expert_rank.attributes = rank_values
              if existing_expert_rank.changed?
                updated_records += 1
                existing_expert_rank
              else
                nil
              end
          else
            new_records += 1
            ExpertRank.new(rank_values)
          end
        end
      end.flatten.compact
      if ranks_to_save.empty?
        import_log "nothing to import"
      else
        import_log "new_records: #{new_records}"
        import_log "updated_records: #{updated_records}"
        import_log "ranks_to_save: #{ranks_to_save.size}"
        ranks_to_save.each(&:save)
      end

      import_log "Done at #{Time.now}"
    rescue Exception => e
      import_log "Exception! #{e.message}: #{e.backtrace.join("\n")}"
    end
  end

  SLUGS = {
    'quarterback'           => %w[194444369 220110223 172841620 165958533 023951042 164430843 163759238],
    'running-back'          => %w[195004044 223423426 173014754 170318935 024434838 164715989 164147854],
    'wide-receiver'         => %w[195412243 223931236 173138734 171057943 024817302 165000659 164506418],
    'tight-end'             => %w[195822348 224437722 172657350 171409065 025317338 165537197 164752061],
    'kicker'                => %w[200431750 225439019 173422504 171828774 025716115 165755022 165050755],
    'defense-special-teams' => %w[200810523 224828451 173639390 172402747 030005478 170048186 165338523]
  }

  ImporterUserAgents = [
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.60 Safari/537.1',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_0) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4',
    'Mozilla/5.0 (Windows NT 6.2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1464.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.60 Safari/537.17',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.2 (KHTML, like Gecko) Chrome/22.0.1216.0 Safari/537.2',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36'
  ]
end
