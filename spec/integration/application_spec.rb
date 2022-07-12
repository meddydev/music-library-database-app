require "spec_helper"
require "rack/test"
require_relative "../../app"

describe Application do
  def reset_tables
    seed_sql = File.read("spec/seeds/music_library.sql")
    connection = PG.connect({ host: "127.0.0.1", dbname: "music_library_test" })
    connection.exec(seed_sql)
  end

  before(:each) do
    reset_tables
  end

  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "POST to /albums" do
    it "creates new album and includes it when getting list of all albums" do
      response = post("/albums", title: "Voyage", release_year: 2022, artist_id: 2)
      album_list = get("albums").body

      expect(response.status).to eq 200
      expect(album_list).to include("Voyage")
    end
  end

  context "GET to /artists" do
    it "returns a list of all the artists with links to each artist's info" do
      response = get("/artists")

      expect(response.status).to eq 200
      expect(response.body).to include('<a href="/artists/1">Pixies</a><br />')
      expect(response.body).to include('<a href="/artists/4">Nina Simone</a><br />')
    end
  end

  context "POST /artists" do
    xit "creates a new artists in the database" do
      response = post("/artists", name: "Wild nothing", genre: "Indie")
      artists = get("/artists").body

      expect(response.status).to eq 200
      expect(artists).to eq "Pixies, ABBA, Taylor Swift, Nina Simone, Wild nothing"
    end
  end

  context "GET to /albums/:id" do
    it "return HTML content for single album" do
      response = get("/albums/2")

      expect(response.status).to eq 200
      expect(response.body).to include("<h1>Surfer Rosa</h1>")
      expect(response.body).to include("<p>Release year: 1988</p>")
      expect(response.body).to include("<p>Artist: Pixies</p>")
    end
  end

  context "GET to /albums" do
    it "returns HTML formatted list of albums" do
      response = get("/albums")

      expect(response.status).to eq 200
      expect(response.body).to include("<h1>Albums</h1>")
      expect(response.body).to include('<a href="/albums/1">Title: Doolittle</a>')
      expect(response.body).to include("Released: 1989")
      expect(response.body).to include('<a href="/albums/12">Title: Ring Ring</a>')
      expect(response.body).to include("Released: 1973")
    end
  end

  context "GET to /artists/:id" do
    it "returns HTML formatted info for single artist" do
      response = get("/artists/1")

      expect(response.status).to eq 200
      expect(response.body).to include("<h1>Pixies</h1>")
      expect(response.body).to include("<p>Genre: Rock</p>")
    end

    it "returns HTML formatted info for a different artist" do
      response = get("/artists/4")

      expect(response.status).to eq 200
      expect(response.body).to include("<h1>Nina Simone</h1>")
      expect(response.body).to include("<p>Genre: Pop</p>")
    end
  end

  context "GET to /albums/new" do
    it "returns an HTML form to add an album" do
      response = get("/albums/new")

      expect(response.status).to eq 200
      expect(response.body).to include('<form method="POST" action="/albums">')
      expect(response.body).to include('<input type="text" name="title" />')
      expect(response.body).to include('<input type="number" name="release_year" />')
      expect(response.body).to include('<input type="number" name="artist_id" />')
      expect(response.body).to include('<input type="Submit" />')
    end
  end

  context "GET to artists/new" do
    it "returns an HTML form to add an album" do
      response = get("/artists/new")

      expect(response.status).to eq 200
      expect(response.body).to include('<form method="POST" action="/artists">')
      expect(response.body).to include('<input type="text" name="name" />')
      expect(response.body).to include('<input type="text" name="genre" />')
      expect(response.body).to include('<input type="Submit" />')
    end
  end
end
