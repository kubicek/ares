require 'net/http'
require 'active_support'
class Ares
  SERVICE_URL = "http://wwwinfo.mfcr.cz/cgi-bin/ares/darv_std.cgi?%s".freeze
  attr_reader :options, :result

  # class methods
  class << self
    # finds subject by any part on ares service
    def find(options)
      return new(options)
    end
  end

  # initializes new ares object 
  def initialize(options)
    @options = options
    @result = Hash.from_xml(Net::HTTP.get_print(URI.parse(SERVICE_URL % self.params)))
  end

  # returns true if subject found on ares, otherwise false
  def found?
    @found ||= !(self.result["Ares_odpovedi"]["Odpoved"]["Pocet_zaznamu"] == '0' ||
      self.result["Ares_odpovedi"]["Odpoved"]["error"])
  end

  # returns params like concatenated options
  def params
    @params ||= options.inject([]) do |res, pair|
       res << "%s=%s" % [pair.first, pair.last]
    end.join('&')
  end

  # returns just answer part
  def answer
    @answer ||= self.result["Ares_odpovedi"]["Odpoved"]["Zaznam"]
  end

  # returns company name
  def company_name
    @company_name ||= self.answer["Obchodni_firma"]
  end

  # returns ico
  def ico
    @company_name ||= self.answer["ICO"]
  end

  # returns subject type
  def subject_type
    @subject_type ||= if self.answer["Identifikace"]["Osoba"].nil?
                        "P"
                      else
                        "F"
                      end
    
  end
end