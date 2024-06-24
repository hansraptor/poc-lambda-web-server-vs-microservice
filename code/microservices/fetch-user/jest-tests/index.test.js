
console.log(`resolve modules from [${process.env.NODE_PATH}]`);

const index = require("../index.js");
// import { handler } from "../src/index.js";

describe(`fetch-user index.handler`, () => {
    const event = {
        description: "local unit test",
        pathParameters: {
            "id": "872b923c-5eb3-4ef6-b2bb-58fbb5b20c68"
        }
    };
    const context = {
        description: "local unit test"
    };

    it(`the item should have the [id] and [readstamp] fields`, async () => {
        const handlerResult = await index.handler(event, context);;
        
        expect(handlerResult).toEqual(expect.objectContaining({
            statusCode: expect.any(Number),
            body: expect.any(String)
        }));
        
        const user = JSON.parse(handlerResult.body);

        expect(user).not.toBeNull();
        expect(user).toEqual(expect.objectContaining({
            id: expect.any(String),
            readstamp: expect.any(String)
        }));
    });
});
