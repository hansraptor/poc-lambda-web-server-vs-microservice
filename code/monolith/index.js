
const express = require("express");
const serverless = require("serverless-http");
const webserver = express();
const port = 3000;
const httpRequestHelper = require("./functions/http-request-helper");

webserver.use(express.json())

// webserver.get("/test", (request, response) => {
//   console.log(`${request.method} ${request.url}`);

//   response.status(200).json({
//     message: `Hello from Terraformed Lambda Monolith!`,
//   })
// });

webserver.use("*", (request, response) => {
  response.status(200).json({
    method: request.method,
    baseUrl: request.baseUrl,
    urlPath: request.path,
    headers: request.headers,
    query: request.query,
    payload: request.body
  });
})

webserver.listen(port, () => {
  console.log(`Server is running on port [${port}]`);
});

module.exports.handler = serverless(webserver);
