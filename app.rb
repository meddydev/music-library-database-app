# file: app.rb
require "sinatra"
require "sinatra/reloader"
require_relative "lib/database_connection"
require_relative "lib/album_repository"
require_relative "lib/artist_repository"

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload "lib/album_repository"
    also_reload "lib/artist_repository"
  end

  get "/albums" do
    repo = AlbumRepository.new
    @albums = repo.all

    return erb(:get_albums)
  end

  post "/albums" do
    title = params[:title]
    release_year = params[:release_year]
    artist_id = params[:artist_id]

    new_album = Album.new
    new_album.title = title
    new_album.release_year = release_year
    new_album.artist_id = artist_id

    repo = AlbumRepository.new
    repo.create(new_album)
    return "Your album has been added!"
  end

  get "/artists" do
    artist_repo = ArtistRepository.new
    @artists = artist_repo.all
    return erb(:get_artists)
  end

  post "/artists" do
    artist = Artist.new
    artist.name = params[:name]
    artist.genre = params[:genre]

    repo = ArtistRepository.new
    repo.create(artist)
  end

  get "/albums/new" do
    return erb(:new_album)
  end
 
  get "/albums/:id" do
    album_id = params[:id]

    album_repo = AlbumRepository.new
    @album = album_repo.find(album_id)
    artist_repo = ArtistRepository.new
    @artist = artist_repo.find(@album.artist_id)
    return erb(:album_info)
  end

  get "/artists/new" do
    return erb(:new_artist)
  end

  get "/artists/:id" do
    artist_id = params[:id]

    artist_repo = ArtistRepository.new
    @artist = artist_repo.find(artist_id)
    return erb(:artist_info)
  end
end
