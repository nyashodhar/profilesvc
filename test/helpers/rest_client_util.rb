module RestClientUtil

  def do_post_with_headers_remote(api_uri, my_body, my_headers)
    begin
      return RestClient.post("#{@my_svc_url}/#{api_uri}", my_body, my_headers)
    rescue => e
      if(defined? e.response)
        return e.response
      else
        raise "do_post_with_headers_remote(): Unexpected error! No response for url = #{@my_svc_url}/#{api_uri}, body = #{my_body}, headers = my_headers, error = #{e}"
      end
    end
  end

  def do_put_with_headers_remote(api_uri, my_body, my_headers)
    begin
      return RestClient.put("#{@my_svc_url}/#{api_uri}", my_body, my_headers)
    rescue => e
      if(defined? e.response)
        return e.response
      else
        raise "do_put_with_headers_remote(): Unexpected error! No response for url = #{@my_svc_url}/#{api_uri}, body = #{my_body}, headers = my_headers, error = #{e}"
      end
    end
  end

  def do_get_with_headers_remote(api_uri, my_headers)
    begin
      return RestClient.get("#{@my_svc_url}/#{api_uri}", my_headers)
    rescue => e
      if(defined? e.response)
        return e.response
      else
        raise "do_get_with_headers_remote(): Unexpected error! No response for url = #{@my_svc_url}/#{api_uri}, headers = my_headers, error = #{e}"
      end
    end
  end

  def create_headers_with_auth_token_remote(auth_token)
    return {'Content-Type' => 'application/json', 'Accept' => 'application/json', 'X-User-Token' => auth_token }
  end

  def create_headers_remote
    return {'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  def get_content_type_remote(response)
    return response.headers[:content_type]
  end

  def assert_response_code_remote(response, expected_response_code)
    if(response == nil)
      raise "Can't assert response code in response, response is blank: #{response}\n"
    end
    if(!response.code.to_s.eql?(expected_response_code.to_s))
      raise "Unexpected response code. Expected response code: #{expected_response_code}, actual response code: #{response.code}\n"
    end
  end


end