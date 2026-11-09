# frozen_string_literal: true

# Small pill shown on top of card previews so that models, collections
# (folders) and creators can be told apart at a glance.
class Components::TypeBadge < Components::Base
  TYPES = {
    model: {icon: "box", klass: "Model"},
    collection: {icon: "folder2", klass: "Collection"},
    creator: {icon: "person", klass: "Creator"}
  }.freeze

  def self.icon_for(type)
    TYPES.fetch(type)[:icon]
  end

  def initialize(type:)
    @type = type
  end

  def view_template
    config = TYPES.fetch(@type)
    span class: "mf-type-badge mf-type-#{@type}" do
      Icon(icon: config[:icon], role: "presentation")
      whitespace
      span { config[:klass].constantize.model_name.human }
    end
  end
end
