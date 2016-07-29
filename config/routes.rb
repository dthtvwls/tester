Rails.application.routes.draw do
    match '(*path)', to: proc { |env| [200, {}, ['OK']] }, via: :all
end
