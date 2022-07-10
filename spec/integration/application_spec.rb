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
      expect(album_list[-6, 6]).to eq "Voyage"
    end
  end

  context "GET to /artists" do
    it "returns a comma separated list of all the artists" do
      response = get("/artists")

      expect(response.status).to eq 200
      expect(response.body).to eq "Pixies, ABBA, Taylor Swift, Nina Simone"
    end
  end

  context "POST /artists" do
    it "creates a new artists in the database" do
      response = post("/artists", name: "Wild nothing", genre: "Indie")
      artists = get("/artists").body

      expect(response.status).to eq 200
      expect(artists).to eq "Pixies, ABBA, Taylor Swift, Nina Simone, Wild nothing"
    end
  end
end
