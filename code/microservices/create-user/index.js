
const dataInterface = require("data-interface");

/*export const */module.exports.handler = async (event, context) => {
  const rawUser = event.body;

  if (!rawUser) {
    return {
      statusCode: 400,
      body: "User payload not provided"
    }
  }

  const user = JSON.parse(rawUser);
  const newUser = await dataInterface.createUser(user);

  return {
    statusCode: 200,
    body: JSON.stringify(newUser),
  };
};
