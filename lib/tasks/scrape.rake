namespace :scrape do
  desc "TODO"
  task wikipedia: :environment do
    url = 'https://sk.wikipedia.org/wiki/%C5%A0peci%C3%A1lne:N%C3%A1hodn%C3%A1'
    doc = Nokogiri::HTML(open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE))
    title = doc.css('title').text
    puts title
    text = doc.css('#mw-content-text .mw-parser-output p').text.gsub(/\(.*?\)/, "")
    puts "Text length = #{text.size}"
    otazky = Sentence.parse(text).map(&:otazka)
    puts
    puts "#{otazky.size} viet"
    dobre_otazky = otazky.delete_if{|otazka| otazka.instance_of? StandardError}
    puts "#{dobre_otazky.size} sa podarilo prehodiť na otázku"
    dobre_otazky.each{|otazka| puts otazka}
  end

  desc "TODO"
  task supermusic: :environment do
  end

end
