module SearchHelper
  def to_price(str)
    str.gsub(/₴|\s+/, "").to_i
  end
end
