module Schools
  class FacultyPolicy < ApplicationPolicy
    def index?
      # All school admins can list faculty (coaches) in a course.
      true
    end

    def create?
      # All school admins can add faculty as long as the course hasn't ended.
      record.present?
    end

    def school_index?
      user.school_admins.where(school: record).present?
    end

    def course_index?
      !record.ended?
    end

    alias destroy? create?
    alias update? create?
    alias update_course_enrollments? create?
    alias update_startup_enrollments? create?

    class Scope < Scope
      def resolve
        current_school.faculty
      end
    end
  end
end
