# Remembers list page display preferences (tile size and items per page)
# chosen from the "View" menu on list pages. Signed-in users have them
# stored in their pagination settings; anonymous visitors in their session.
module ListDisplaySettings
  extend ActiveSupport::Concern

  included do
    before_action :remember_list_display_settings
  end

  private

  def remember_list_display_settings
    changes = {}
    if params["per_page"].present?
      per_page = params["per_page"].to_i
      changes["per_page"] = per_page if SiteSettings::UserDefaults::PER_PAGE_RANGE.cover?(per_page)
    end
    if SiteSettings::UserDefaults::TILE_SIZES.include?(params["tile_size"])
      changes["tile_size"] = params["tile_size"]
    end
    return if changes.empty?
    if current_user
      current_user.update!(pagination_settings: helpers.pagination_settings.to_h.merge(changes))
    else
      session["pagination_settings"] = (session["pagination_settings"] || {}).merge(changes)
    end
  end
end
