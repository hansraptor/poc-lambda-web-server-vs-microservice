
export const handler = async (event, context) => {
  // TODO implement
  console.log(event);

  const response = {
    statusCode: 200,
    body: JSON.stringify(`Hello from Terraformed Lambda!`),
  };

  return response;
};

