# encoding: utf-8
# frozen_string_literal: true

class TimelineEventType < ApplicationRecord
  has_many :timeline_events, dependent: :restrict_with_error

  TYPE_END_ITERATION = 'end_iteration'
  TYPE_NEW_DECK = 'new_product_deck'
  TYPE_NEW_WIREFRAME = 'new_wireframe'
  TYPE_NEW_PROTOTYPE = 'new_prototype'
  TYPE_NEW_VIDEO = 'new_video'
  TYPE_HELP_WANTED = 'help_wanted'
  TYPE_RESUME_SUBMISSION = 'resume_submission'

  TYPE_STAGE_IDEA = 'moved_to_idea_discovery'
  TYPE_STAGE_PROTOTYPE = 'moved_to_prototyping'
  TYPE_STAGE_CUSTOMER = 'moved_to_customer_validation'
  TYPE_STAGE_EFFICIENCY = 'moved_to_efficiency'
  TYPE_STAGE_SCALE = 'moved_to_scale'

  STAGES = [TYPE_STAGE_IDEA, TYPE_STAGE_PROTOTYPE, TYPE_STAGE_CUSTOMER, TYPE_STAGE_EFFICIENCY, TYPE_STAGE_SCALE].freeze

  STAGE_NAMES = {
    TYPE_STAGE_IDEA => 'Idea Discovery',
    TYPE_STAGE_PROTOTYPE => 'Prototyping',
    TYPE_STAGE_CUSTOMER => 'Customer Validation',
    TYPE_STAGE_EFFICIENCY => 'Efficiency',
    TYPE_STAGE_SCALE => 'Scale'
  }.freeze

  ROLE_ENGINEERING = 'Engineering'
  ROLE_PRODUCT = 'Product'
  ROLE_DESIGN = 'Design'
  ROLE_TEAM = 'Team'
  ROLE_FOUNDER = 'Founder'
  ROLE_OTHER = 'Other'

  def self.valid_roles
    [ROLE_ENGINEERING, ROLE_PRODUCT, ROLE_TEAM, ROLE_DESIGN, ROLE_FOUNDER, ROLE_OTHER]
  end

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
  validates :badge, presence: true
  validates :role, inclusion: { in: valid_roles }

  scope :moved_to_stage, -> { where(key: stage_keys) }
  scope :suggested_for, ->(startup) { where('suggested_stage LIKE ?', "%#{startup.current_stage}%").where.not(id: startup.current_stage_event_types.map(&:id)) }

  def founder_event?
    role == ROLE_FOUNDER
  end

  mount_uploader :badge, BadgeUploader
  process_in_background :badge

  attr_accessor :copy_badge_from

  before_validation do
    self.badge = TimelineEventType.find(copy_badge_from).badge if copy_badge_from.present?
  end

  def sample
    placeholder_text = sample_text.present? ? sample_text : "What's been happening?"
    placeholder_text += "\n\nProof Required: #{proof_required}" if proof_required.present?
    placeholder_text
  end

  def end_iteration?
    key == TYPE_END_ITERATION
  end

  def new_deck?
    key == TYPE_NEW_DECK
  end

  def new_wireframe?
    key == TYPE_NEW_WIREFRAME
  end

  def new_prototype?
    key == TYPE_NEW_PROTOTYPE
  end

  def new_video?
    key == TYPE_NEW_VIDEO
  end

  def resume_submission?
    key == TYPE_RESUME_SUBMISSION
  end

  def self.stage_keys
    [TYPE_STAGE_IDEA, TYPE_STAGE_PROTOTYPE, TYPE_STAGE_CUSTOMER, TYPE_STAGE_EFFICIENCY, TYPE_STAGE_SCALE]
  end

  def stage_change?
    TimelineEventType.stage_keys.include?(key)
  end

  def self.end_iteration
    find_by(key: TYPE_END_ITERATION)
  end

  def self.help_wanted
    find_by(key: TYPE_HELP_WANTED)
  end
end
