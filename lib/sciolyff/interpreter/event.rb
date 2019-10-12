# frozen_string_literal: true

require 'sciolyff/interpreter/model'

module SciolyFF
  # Models an instance of a Science Olympiad event at a specific tournament
  class Interpreter::Event < Interpreter::Model
    def link_to_other_models(interpreter)
      super
      @placings = interpreter.placings.select { |p| p.event == self }
      @placings_by_team =
        @placings.group_by(&:team).transform_values!(&:first)

      @placings.freeze
    end

    attr_reader :placings

    def name
      @rep[:name]
    end

    def trial?
      @rep[:trial] == true
    end

    def trialed?
      @rep[:trialed] == true
    end

    def high_score_wins?
      @rep[:scoring] == 'high'
    end

    def low_score_wins?
      !high_score_wins?
    end

    def placing_for(team)
      @placings_by_team[team]
    end

    def competing_teams
      return placings.map(&:team) if trial?

      placings.map(&:team).reject(&:exhibition?)
    end
  end
end