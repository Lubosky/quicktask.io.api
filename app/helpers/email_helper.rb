module EmailHelper
  include EmailUrlHelper

  def render_email_plaintext(text)
    Rinku.auto_link(simple_format(html_escape(text)), :all, 'target="_blank"').html_safe
  end

  def formatted_time_in_zone(time, zone)
    return unless time && zone
    time.in_time_zone(TimeZoneConverter.convert zone).strftime('%l:%M%P - %A %-d %b %Y')
  end

  def formatted_time_relative_to_age(time)
    current_time = Time.zone.now
    if time.to_date == Time.zone.now.to_date
      l(time, format: :for_today)
    elsif time.year != current_time.year
      l(time.to_date, format: :for_another_year)
    else
      l(time.to_date, format: :for_this_year)
    end
  end
end
