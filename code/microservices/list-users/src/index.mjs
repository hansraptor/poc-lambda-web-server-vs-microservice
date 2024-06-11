
const dataInterface = require("./data-interfact");
const businessLogic = require("./business-logic");

export const handler = async (event, context) => {
  const users = dataInterface.fetchUsers();
  const annotatedUsers = businessLogic.annotateUsers(users);

  return {
    statusCode: 200,
    body: JSON.stringify({
      input: { event, context },
      output: annotatedUsers
    })
  };
};
