
const index = require("../src/index");
// import { handler } from "../src/index.js";

describe(`annotateUsers`, () => {
    const event = {
        description: "local unit test"
    };
    const context = {
        description: "local unit test"
    };

    it(`all items should have the [readstamp] field`, async () => {
        const handlerResult = await index.handler(event, context);;
        
        expect(handlerResult).toEqual(expect.objectContaining({
            statusCode: expect.any(Number),
            body: expect.any(String)
        }));
        
        const responseBody = JSON.parse(handlerResult.body);

        expect(responseBody).toEqual(expect.objectContaining({
            input: expect.objectContaining({
                event: expect.objectContaining(event),
                context: expect.objectContaining(context)
            }),
            output: expect.anything()
        }));
    });
});
