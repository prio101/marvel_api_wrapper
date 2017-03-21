defmodule MarvelApiWrapper do
  @moduledoc """
  Documentation for MarvelApiWrapper.
  """
  def help do
    IO.puts """
      Marvel API Wrapper For Elixir Lang / Erlang
      Write MarvelApiWrapper.api(api_key, api_secret, param)
    """
  end

  def api_auth(time_stamp, api_key, api_private) do
    generate_hash(time_stamp, api_key, api_private)
  end

  def generate_hash(time_stamp, api_key, api_private) do
    concated_data = "#{time_stamp}#{api_private}#{api_key}"
    :crypto.hash(:md5, concated_data )
    |> Base.encode16(case: :lower)
  end

  def api(api_key, api_secret, param) do
    datetime = Timex.now
    time_stamp = Timex.Protocol.to_unix(datetime)
    hash = api_auth(time_stamp, api_key, api_secret)
    get_individual_character(time_stamp, api_key, param, hash)
  end

  def get_individual_character(time_stamp, api_key, character_id, hash) do
    base_url(time_stamp, api_key, character_id, hash)
    |> HTTPoison.get
    |> get_body_data
  end

  defp get_body_data({:ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body)}
  end

  defp base_url(time_stamp, api_key, param, hash) do
    "https://gateway.marvel.com:443/v1/public/characters/#{param}?ts=#{time_stamp}&apikey=#{api_key}&hash=#{hash}"
  end
end
