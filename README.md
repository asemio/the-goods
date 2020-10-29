1. Make your changes to the Dockerfile
2. Update the version numbers in the commands in this very README
3. Run the commands:

```
docker build --squash -t asemio/the-goods:0.3.7 .
docker push asemio/the-goods:0.3.7
```
