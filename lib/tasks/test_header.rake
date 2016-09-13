desc 'Test header length'
task :test_header_length, [:host, :length] do |t, args|
    args.with_defaults host: 'localhost:8080', length: '16384'

    test_string = SecureRandom.urlsafe_base64(args[:length].to_i * 3/4)
    raise unless RestClient.get("http://#{args[:host]}/?#{test_string}") == test_string
end
