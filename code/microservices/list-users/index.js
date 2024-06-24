
const dataInterface = require("data-interface");
const businessLogic = require("business-logic");

/*export const */module.exports.handler = async (event, context) => {
  const users = await dataInterface.listUsers();
  const annotatedUsers = await businessLogic.annotateUsers(users);

  return {
    statusCode: 200,
    // body: JSON.stringify({
    //   input: { event, context },
    //   output: annotatedUsers
    // })
    body: JSON.stringify(annotatedUsers)
  };
};
