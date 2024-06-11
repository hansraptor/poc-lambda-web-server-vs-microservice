
const businessLogic = require("../src/business-logic");

describe(`annotateUsers`, () => {
    const unannotatedUsers = [{ index: 0 }, { index: 1 }]

    it(`all items should have the [readstamp] field`, async () => {
        const annotatedUsers = await businessLogic.annotateUsers(unannotatedUsers);
        
        for (annotatedUser of annotatedUsers) {
            expect(annotatedUser).toEqual(expect.objectContaining({
                readstamp: expect.any(Number)
            }));
        }
    });
});
