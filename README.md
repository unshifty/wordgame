# Building and Deploying

* If changing domain for deployment update new domains in
  * config/prod.exs
  * apps/wordplay/lib/wordplay_web/Endpoint.ex

## Publishing Docker Image

* Edit docker.bat with new version
* Run ```docker.bat build`` to build the image
* Run ```docker.bat push``` to publish
* sign in to host
  * edit docker-compose.yml and update image version
    * image: "docker.pkg.github.com/okadoke/wordgame/wordgames:<NEW_VERSION>"
  * docker-compose down
  * docker-compose up -d

**TODO: Add description**

