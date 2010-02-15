$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'time'
require 'qer/todo'
module Qer
  VERSION = '0.2.4'
end

class Time
  def self.time_ago(from_time, to_time = Time.now)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
       when 0..1            then "> #{distance_in_seconds} sec ago"
       when 2..44           then "> #{distance_in_minutes} min ago"
       when 45..89          then "~ 1 hr ago"
       when 90..1439        then "~ #{(distance_in_minutes.to_f / 60.0).round} hrs ago"
       when 1440..2879      then "~ 1 day ago"
       when 2880..43199     then "~ #{(distance_in_minutes / 1440).round} days ago"
       when 43200..86399    then "~ 1 month ago"
       when 86400..525599   then "~ #{(distance_in_minutes / 43200).round} months ago"
       when 525600..1051199 then "~ 1 year ago"
       else                      "> #{(distance_in_minutes / 525600).round} years ago"
    end
  end
end
