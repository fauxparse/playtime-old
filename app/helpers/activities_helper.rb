module ActivitiesHelper
  def date_param(date)
    date.strftime("%Y/%m/%d").gsub(/\/0/, "/")
  end
end
