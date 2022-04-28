# Lyrisis Server
Server-side code for the lyrics generation server-client application.

Deploys the model by serving it with Flask.

Run the server with:
```
docker build -t server .
docker run -p 3000:3000 -e PORT=3000 server
```