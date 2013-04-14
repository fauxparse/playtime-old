class ActivityPresenter < SimpleDelegator
  attr_reader :group

  def initialize(group, view)
    super(view)
    @group = group
  end
  
  def activity
    group.first
  end

  def render_activity_group
    locals = { jester: activity.jester, activities: group, presenter: self }
    time = if date == Date.today
      time_ago_in_words(group.last.time) + " ago"
    else
      group.first.time.strftime "%l:%M%P"
    end

    content_tag :li, class: activity.action do
      render(partial_path, locals) + " " + content_tag(:small, time)
    end
  end
  
  def partial_path
    partial_paths.detect do |path|
      lookup_context.template_exists? path, nil, true
    end || raise("No partial found for activity in #{partial_paths}")
  end

  def partial_paths
    [
      "activities/#{activity.trackable_type.pluralize.underscore}/#{activity.action}",
      "activities/#{activity.trackable_type.underscore}",
      "activities/activity"
    ]
  end
  
  def jester
    link_to activity.jester, "/#/jesters/#{activity.jester.slug}"
  end
  
  def dates
    months = {}
    group.each do |activity|
      date = Date.civil *activity.trackable_id.split("-").map(&:to_i)
      key = date.strftime "%Y-%m"
      (months[key] ||= []).push date
    end
    months = months.to_a.sort_by(&:first).map do |key, dates|
      dates.sort!
      dates.uniq!
      if dates.length > 3
        "#{dates.length} dates in #{dates.first.strftime "%B"}"
      else
        numbers = dates.map { |date| show_link date }
        "the #{numbers.to_sentence} of #{dates.first.strftime "%B"}"
      end
    end
    months.to_sentence.html_safe
  end
  
  def show_link(date)
    link_to date.day.ordinalize, "/#/shows/#{date.strftime("%Y/%m/%d").gsub(/\/0/, "/")}"
  end
  
  
end