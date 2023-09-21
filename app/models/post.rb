class Post < ApplicationRecord

  BUNDLE = {
    "IMG": [[5, 450], [10, 800]],
    "FLAC": [[3, 427.50], [6, 810], [9, 1147.50]],
    "VID": [[3, 570], [5, 900], [9, 1530]]
  }

  # ToDo: The document did not specify the individual pricing for each post.
  # r represent the number of posts not included in the bundle.
  # However, we do not include it in the output for now.

  def to_bundles(y, format)
    x = y
    r = 0
    bundle = []
    bundler = BUNDLE[format.to_sym].map(&:first).sort.reverse
    while !bundler.empty?
      hash = {}
      bundler.each_with_index do |elem, idx|
        next if elem > x
        hash[elem.to_s] = (x / elem)
        x = x % elem
        hash["r"] = x
      end

      bundle << hash

      # Rails.logger.info bundle

      if x > 0
        bundler.slice!(0)
        x = y
      else
        bundler = []
      end

    end

    bundle = bundle.sort_by!{|item| [item["r"], item.keys.count]}.first

    text = ""
    total = 0

    bundle.keys.excluding("r").each do |key|
      bundle_price = BUNDLE[format.to_sym].find{|x| x[0] == key.to_i}[1]
      total = total + (bundle[key] * bundle_price)
      text.concat"#{bundle[key]} x #{key} $#{bundle_price} "
    end

    "#{y} #{format} $#{total}: ".concat text

  end

  def generate_bundles
    data = {}
    input.scan(/(\d+ (IMG|FLAC|VID|img|flac|vid)(?!\S))/).each do |match|
      data[match[1]] ||= 0
      data[match[1]] = data[match[1]] + match[0].split(" ")[0].to_i
    end

    output = {}
    data.transform_keys!{ |key| key.to_s.upcase } #we can be a bit lenient on the format
    data.keys.each do |key|
      output[key] = to_bundles(data[key], key)
    end

    # Rails.logger.debug output

    output

  end

end
