# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Word.delete_all

File.open('db/seeds/lemmaformtag.txt') do |f|
  i = 0
  f.each_line do |line|
    i += 1
    parts = line.split("\t")
    Word.create(
            word: parts[1].strip,
            lemma: parts[0].strip,
            tag: parts[2].strip
    )
    if i % 100 == 0
      print "#{i * 100 / 3305975}.#{'%02d' % ((i *10000 / 3305975) % 100)}%\r"
      $stdout.flush
    end
  end
  puts "Finished loading #{Word.count} words."
end
