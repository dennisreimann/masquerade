module PersonasHelper

  # get list of codes and names sorted by country name
  def countries_for_select
    I18nData.countries.map{|pair| pair.reverse}.sort{|x,y| x.first <=> y.first}
  end

end
