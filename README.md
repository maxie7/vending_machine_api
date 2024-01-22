## VendingMachine API

To start the project locally:

- Run `docker-compose up -d` to start the database
- Get the dependencies `mix deps.get`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

To test use Postman (the collection is at `/test/postman` folder) or Curl.
Example of Curl request:

```
curl -H "Content-Type: application/json" -X POST -d '{"username":"test1","password":"test1"}' http://localhost:4000/api/users/sign_in -c cookies.txt -b cookies.txt -i
```

For resolving CORS `corsica` package is used (the port for frontend is 5174)

To run tests: `mix test`
