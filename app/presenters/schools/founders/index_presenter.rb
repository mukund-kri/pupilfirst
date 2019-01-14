module Schools
  module Founders
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def teams
        @course.startups
      end

      def team?(startup)
        @team ||= Hash.new do |hash, s|
          hash[s] = s.founders.count > 1
        end

        @team[startup]
      end
    end
  end
end
