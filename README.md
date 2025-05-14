# Bitnet server docker image

This project uses llama server to serve latest bitnet model. 

## Setup instructions

Build the docker image:
```
docker build -t fastapi_bitnet .
```

Run the docker image:
```
docker run -d --name ai_container -p 8080:8080 fastapi_bitnet
```

Once it's running navigate to http://127.0.0.1:8080/docs

---

Note:

f seeking to use this in production, make sure to extend the docker image with additional authentication steps. In its current state it's intended for use locally.