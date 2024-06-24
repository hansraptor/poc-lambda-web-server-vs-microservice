
const dataInterface = require("data-interface");
const businessLogic = require("business-logic");

/*export const */module.exports.handler = async (event, context) => {
  const idParameterName = "id";
  const userId = event.pathParameters[idParameterName];

  if (!userId) {
    return {
      statusCode: 400,
      body: `Path parameter [${idParameterName}] is required.`,
    };
  }

  const targetUser = await dataInterface.fetchUser(userId);

  if (!targetUser) {
    return {
      statusCode: 404,
      body: `Could not find a user with [${idParameterName}] [${userId}].`,
    };
  }
  
  const annotatedUser = await businessLogic.annotateUser(targetUser);
  
  return {
    statusCode: 200,
    body: JSON.stringify(annotatedUser),
  };
};
