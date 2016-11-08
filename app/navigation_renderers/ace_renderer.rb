# Clone from simple-navigation-bootstrap
class AceRenderer < SimpleNavigation::Renderer::Base
  def render(item_container)
    config_selected_class = SimpleNavigation.config.selected_class
    SimpleNavigation.config.selected_class = 'active'
    list_content = item_container.items.inject([]) do |list, item|
      li_options = item.html_options.reject { |k, v| k == :link || k == :id }
      icon = li_options.delete(:icon)
      split = (include_sub_navigation?(item) and li_options.delete(:split))
      li_content = tag_for(item, item.name, icon, split)
      li_content << content_tag(:b, '', :class => 'arrow')
      if include_sub_navigation?(item)
        if split
          lio = li_options.dup
          lio[:class] = [li_options[:class], 'dropdown-split-left'].flatten.compact.join(' ')
          list << content_tag(:li, li_content, lio)
          item.html_options[:link] = nil
          li_options[:id] = nil
          li_content = tag_for(item)
        end
        item.sub_navigation.dom_class = [item.sub_navigation.dom_class, 'submenu', split ? 'pull-right' : nil].flatten.compact.join(' ')
        li_content << render_sub_navigation_for(item)
        # li_options[:class] = [li_options[:class], 'dropdown', split ? 'dropdown-split-right' : nil].flatten.compact.join(' ')
      end
      list << content_tag(:li, li_content, li_options)
    end.join
    SimpleNavigation.config.selected_class = config_selected_class
    if skip_if_empty? && item_container.empty?
      ''
    else
      # content_tag(:ul, list_content, {:id => item_container.dom_id, :class => item_container.dom_class})
      content_tag(:ul, list_content, {:class => item_container.dom_class})
    end
  end

  protected

  def tag_for(item, name = '', icon = nil, split = false)
    unless item.url or include_sub_navigation?(item)
      return item.name
    end
    url = item.url
    link = Array.new
    link << content_tag(:i, '', :class => [icon, 'menu-icon'].flatten.compact.join(' ')) unless icon.nil?
    link << content_tag(:span, name, class: 'menu-text')
    if include_sub_navigation?(item)
      item_options = item.html_options
      item_options[:link] = Hash.new if item_options[:link].nil?
      item_options[:link][:class] = Array.new if item_options[:link][:class].nil?
      unless split
        item_options[:link][:class] << 'dropdown-toggle'
        link << content_tag(:b, '', :class => 'arrow fa fa-angle-down')
      end
      item.html_options = item_options
    end
    link_to(link.join(" ").html_safe, url, options_for(item))
  end
end
