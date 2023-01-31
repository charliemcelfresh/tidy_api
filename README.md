### tidy_api: Self-generating Sinatra + Sequel API

##### Prerequisites
* Ruby 3.2
* PostgreSQL, 14.x preferred

##### Install
* Create two databases: `tidy_api_test` and `tidy_api_development`
* Run migrations and load seeds: `rake db:migrate` and `rake db:seed`
* Start the server: `rackup`
* Make some requests:

```
curl --location --request GET 'http://localhost:9292/api/v1/posts'
```
```
curl --location --request GET 'http://localhost:9292/api/v1/posts/1'
```

