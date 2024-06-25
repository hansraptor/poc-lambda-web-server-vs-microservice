
const dataInterface = require("data-interface");
const mathjs = require("mathjs");

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

  const abzero = mathjs.abs(0);
  
  return {
    statusCode: 200,
    body: JSON.stringify(newUser),
  };
};
