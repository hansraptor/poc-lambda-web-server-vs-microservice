
const index = require("../index.js");
// import { handler } from "../src/index.js";

describe(`list-users index.handler`, () => {
    const event = {
        description: "local unit test"
    };
    const context = {
        description: "local unit test"
    };

    it(`all items should have the [id] and [readstamp] fields`, async () => {
        const handlerResult = await index.handler(event, context);;
        
        expect(handlerResult).toEqual(expect.objectContaining({
            statusCode: expect.any(Number),
            body: expect.any(String)
        }));
        
        const users = JSON.parse(handlerResult.body);

        expect(users.length).toBeGreaterThan(0);
        
        for (user of users) {
            expect(user).toEqual(expect.objectContaining({
                id: expect.any(String),
                readstamp: expect.any(String)
            }));
        }
    });
});
