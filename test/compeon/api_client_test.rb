require 'test_helper'

class Compeon::ApiClientTest < Minitest::Test
  HTTP_VERBS = %w[get put patch post].freeze
  BASE_URL = 'http://baseurl.tld'.freeze

  def setup
    @client = ::Compeon::APIClient.new(version: 1, token: 'foo', url: BASE_URL)

    stub_request(:any, /some-url/).to_return { |request| { body: request.body } }
  end

  def test_that_it_has_a_version_number
    refute_nil ::Compeon::ApiClient::VERSION
  end

  def test_that_it_transforms_all_segments_but_not_the_query_string
    response = @client.get(:some_url, :more_url, query: 'a-dasherized-query')

    assert_equal("#{BASE_URL}/v1/some-url/more-url?a-dasherized-query", response.env.url.to_s)
  end

  def test_that_it_can_handle_a_query_string
    HTTP_VERBS.each do |verb|
      path_with_query = "#{BASE_URL}/v1/some-url?the-query"
      response = @client.send(verb, 'some_url', query: 'the-query')

      assert_equal(path_with_query, response.env.url.to_s)
    end
  end

  def test_that_it_can_handle_an_empty_query_string
    HTTP_VERBS.each do |verb|
      path_without_query = "#{BASE_URL}/v1/some-url"

      empty_string_query_response = @client.send(verb, 'some_url', query: '')
      nil_query_response = @client.send(verb, 'some_url', query: nil)
      no_query_passed_response = @client.send(verb, 'some_url')

      assert_equal(path_without_query, empty_string_query_response.env.url.to_s)
      assert_equal(path_without_query, nil_query_response.env.url.to_s)
      assert_equal(path_without_query, no_query_passed_response.env.url.to_s)
    end
  end

  def test_that_it_can_handle_a_query_string_and_a_body
    (HTTP_VERBS - ['get']).each do |verb|
      path_with_query = "#{BASE_URL}/v1/some-url?the-query"
      response = @client.send(verb, 'some_url', query: 'the-query', data: { some: 'data' })

      assert_equal(path_with_query, response.env.url.to_s)
      assert_equal({ data: { some: 'data' } }, response.body)
    end
  end
end
