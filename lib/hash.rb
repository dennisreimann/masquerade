class Hash
  def except(*keys)
    self.reject { |k,v| keys.include?(k.to_sym) }
  end
  
  def only(*keys)
    self.dup.reject { |k,v| !keys.include?(k.to_sym) }
  end
end