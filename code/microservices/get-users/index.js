
export const handler = async (event) => {
    // TODO implement
    console.log(event);
    
    const response = {
      statusCode: 200,
      body: JSON.stringify(`Hello from Terraform Lambda Microservice!`),
    };
    
    return response;
  };
  