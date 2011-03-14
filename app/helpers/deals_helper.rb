module DealsHelper
  def collection_for_status_select
    values = Deal::STATUSES
    values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}.collect{|k| [l(values[k][:name]), k]}
  end
end
