# frozen_string_literal: true

# Dropdown on list pages for choosing tile size and items per page.
# The choice is remembered (see ListDisplaySettings).
class Components::ViewMenu < Components::Base
  register_value_helper :pagination_settings
  register_value_helper :tile_size

  def initialize(filter: nil)
    @filter = filter
  end

  def view_template
    div class: "btn-group" do
      button type: "button", data: {bs_toggle: "dropdown"}, aria: {expanded: "false"}, class: "btn btn-sm dropdown-toggle" do
        Icon(icon: "grid-3x3-gap")
        whitespace
        span { t("components.view_menu.label") }
      end
      ul class: "dropdown-menu dropdown-menu-end" do
        DropdownHeader text: t("components.view_menu.tile_size")
        # i18n-tasks-use t('components.view_menu.tile_sizes.large')
        # i18n-tasks-use t('components.view_menu.tile_sizes.medium')
        # i18n-tasks-use t('components.view_menu.tile_sizes.small')
        {"large" => "grid", "medium" => "grid-3x2-gap", "small" => "grid-3x3-gap"}.each do |size, icon|
          DropdownItem icon: icon,
            label: t("components.view_menu.tile_sizes.%{size}" % {size: size}),
            path: view_url(tile_size: size),
            active: tile_size == size
        end
        DropdownDivider()
        DropdownHeader text: t("components.view_menu.per_page")
        SiteSettings::UserDefaults::PER_PAGE_OPTIONS.each do |count|
          DropdownItem label: count.to_s,
            path: view_url(per_page: count),
            active: pagination_settings["per_page"].to_i == count
        end
      end
    end
  end

  private

  # Stay on the current list with the same filters; go back to the first page
  # since the page boundaries change.
  def view_url(options)
    url_for(options.merge(@filter&.to_params || {}))
  end
end
