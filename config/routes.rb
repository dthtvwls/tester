Rails.application.routes.draw do
    match '(*path)', to: proc { |env| [200, {}, [env['QUERY_STRING']]] }, via: :all
end
