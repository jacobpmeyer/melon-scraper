# frozen_string_literal: true

require "CSV"
require "pry"



## Scratch

require "open-uri"
require "net/http"
require "nokogiri"


#response = Net::HTTP.get_response(uri)
#puts response.body.split("\n")

album_blocks = []
loop do
  i = album_blocks.length + 1
  page = i == 1 ? "" : "#{i}/"
  begin
    html = URI.open("https://www.albumoftheyear.org/publication/57-the-needle-drop/reviews/#{page}")
  rescue
    break
  end
  response = Nokogiri::HTML(html)
  album_block = response.css("div.albumBlock")
  album_blocks << album_block
end

# Album header
parsed_albums = [
  [
    "Review # (roughly)",
    "Artist Name",
    "Album Name",
    "Melon's Rating",
    "Link To Review"
  ]
]

# Individual album data
block_count = album_blocks.length

if block_count > 1
  last_block_count = album_blocks[-1].length
  albums_per_block = album_blocks[0].length
  total_album_count = (block_count - 1) * albums_per_block + last_block_count
elsif block_count == 1
  total_album_count = album_blocks[0].length + 1
else
  total_album_count = 0
end

album_blocks.each do |album_list|
  album_list.each.with_index do |album, i|
    review_num = total_album_count -= 1
    artist_name = album.children[1].children[0].children[0].text
    album_name = album.children[2].children[0].children[0].text
    rating_block = album.children[3].children[0]
    if rating_block.nil?
      rating = 0
      review_link = "miss this one"
    else
      rating = rating_block.children[0].children[0].children[0].text[0..-2].to_i
      review_link = rating_block.children[1].children[0].attributes["href"].value
    end

    parsed_album = [review_num, artist_name, album_name, rating, review_link]
    parsed_albums << parsed_album
  end
end

p = parsed_albums[1..-1].select { |album| album[3] >= 7 }

csv = CSV.open("jacobs_melon_list.csv", "w") do |csv|
  p.each do |album|
    csv << album
  end
end

csv = CSV.open("melon_list.csv", "w") do |csv|
  parsed_albums.each do |album|
    album[2] = album[2] == 0 ? "None" : album[2]
    csv << album
  end
end




#res_string = File.read("./copy_of_response.txt")
