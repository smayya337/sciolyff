# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Scores < Minitest::Test
    def setup
      skip unless SciolyFF.rep.instance_of? Hash
      @scores = SciolyFF.rep['Scores']
      skip unless @scores.instance_of? Array
    end

    def test_has_valid_scores
      @scores.each do |score|
        assert_instance_of Hash, score
      end
    end

    def test_each_score_does_not_have_extra_info
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        a = %w[event team participated disqualified score] << 'tiebreaker place'
        info = Set.new a
        assert Set.new(score.keys).subset? info
      end
    end

    def test_each_score_has_valid_event
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        assert_instance_of String, score['event']
        event_names = SciolyFF.rep['Events'].map { |e| e['name'] }
        assert_includes event_names, score['event']
      end
    end

    def test_each_score_has_valid_team
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        assert_instance_of Integer, score['team']
        team_numbers = SciolyFF.rep['Teams'].map { |t| t['number'] }
        assert_includes team_numbers, score['team']
      end
    end

    def test_each_score_has_valid_participated
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        if score.key? 'participated'
          assert_includes [true, false], score['participated']
        end
      end
    end

    def test_each_score_has_valid_disqualified
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        if score.key? 'disqualified'
          assert_includes [true, false], score['disqualified']
        end
      end
    end

    def test_each_score_has_valid_score
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        next if score['disqualified'] == true ||
                score['participated'] == false

        assert_kind_of Numeric, score['score']
      end
    end

    def test_each_score_has_valid_tiebreaker_place
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        max_place = @scores.count do |s|
          s['event'] == score['event'] &&
            s['score'] == score['score']
        end
        assert_instance_of Integer, score['tiebreaker place']
        assert_includes 1..max_place, score['tiebreaker place']
      end
    end

    def test_scores_are_unique_for_event_and_team
      skip unless SciolyFF.rep['Teams'].instance_of? Array

      SciolyFF.rep['Teams'].each do |team|
        next unless team.instance_of? Hash

        assert_nil @scores.select { |s| s['team'] == team['number'] }
                          .map { |s| s['event'] }
                          .compact
                          .uniq!
      end
    end
  end
end