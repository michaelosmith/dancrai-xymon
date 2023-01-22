Ohai.plugin :Ovfconf do
  require 'nokogiri'

  provides 'ovfconf'

  collect_data :default do
    ovfconf(Mash.new)
    file = File.open("/tmp/ovfEnv.xml") { |f| Nokogiri::XML(f) }
    elements = file.css("Environment PropertySection Property")

    elements.each do |element|
      key = element.attributes["key"].text
      ovfconf[key] = element.attributes["value"].text
    end

  end
end
