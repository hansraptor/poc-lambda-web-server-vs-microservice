
const express = require("express");
const serverless = require("serverless-http");
const webserver = express();
const port = 3000;

webserver.get("/test", (request, response) => {
  console.log(`${request.method} ${request.url}`);

  response.status(200).json({
    message: `Hello from Terraformed Lambda Monolith!`,
  })
});

webserver.listen(port, () => {
  console.log(`Server is running on port [${port}]`);
});

module.exports.handler = serverless(webserver);
