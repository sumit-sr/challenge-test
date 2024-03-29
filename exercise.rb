# frozen_string_literal: true

class Challenge
  require 'net/http'
  require 'json'

  TYPES = { 'IssuesEvent' => 7, 'IssueCommentEvent' => 6, 'PushEvent' => 5,
      'PullRequestReviewCommentEvent' => 4, 'WatchEvent' => 3, 'CreateEvent' => 2 }.freeze

  def self.api_url
    'https://api.github.com/users/dhh/events/public'
  end

  def self.calculate_score
    @response.map { |commit| TYPES[commit['type']] || 1 }.sum
  end

  def self.dhh_score_challenge
    initialize_a_new_get_request(api_url)
    "DHH's github score is #{calculate_score}"
  rescue StandardError => e
    puts "Rescued2: #{e.inspect}"
  end

  def self.initialize_a_new_get_request(url)
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    request['content-type'] = 'application/json'
    req_options = { use_ssl: uri.scheme == 'https' }
    request_for_api_call(uri.hostname, uri.port, req_options, request)
    raise 'There is some issue while fetching data from URL, please try again.' if missing_response?
  end

  def self.request_for_api_call(hostname, port, options, request)
    response = Net::HTTP.start(hostname, port, options) do |http|
      http.request(request)
    end
    @response = JSON.parse(response.body)
  end

  def self.missing_response?
    @response.empty? || !@response.is_a?(Array)
  end
end

puts Challenge.dhh_score_challenge

