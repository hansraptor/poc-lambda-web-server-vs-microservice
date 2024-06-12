
const dataInterface = require("./data-interfact");
const businessLogic = require("./business-logic");

/*export const */module.exports.handler = async (event, context) => {
  const users = await dataInterface.fetchUsers();
  const annotatedUsers = await businessLogic.annotateUsers(users);

  return {
    statusCode: 200,
    body: JSON.stringify({
      input: { event, context },
      output: annotatedUsers
    })
  };
};
