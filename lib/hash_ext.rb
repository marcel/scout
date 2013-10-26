class Hash
  def pair_wise(other_hash, &block)
    inject({}) do |new_hash, (k, v)|
      new_hash[k] = block.call(v, other_hash[k])
      new_hash
    end
  end
end