module ApplicationHelper
  def fa_icon(classes)
    raw("<i class=\"fa #{classes}\"></i> ")
  end

  def page_title
    ['lolIB', content_for(:title)].compact.join(' - ')
  end

  def display_time time
    if time
      # ('<em class="tooltip-container">' + time_ago_in_words(time) + ' ago <span class="tooltip tooltip-style1">' + time.to_s + '</span></em>').html_safe
      time_ago_in_words(time) + ' ago'
    else
      'no time logged'
    end
  end

  def page_heading(title)
    content_for(:title) { title }
    content_tag(:h1, title)
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    if defined?(sort_column)
      icon = column == sort_column ? fa_icon('fa-sort-' + sort_direction) : ''
      direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
      link_to(title, {:sort => column, :direction => direction}) + ' ' + icon
    else
      title
    end
  end
end
