
const dataInterface = require("../src/data-interfact");

describe(`fetchUsers`, () => {
    it(`result should not be empty and each should include an id field`, async () => {
        const users = await dataInterface.fetchUsers();

        expect(users.length).toBeGreaterThan(0);
        
        for (user of users) {
            expect(user).toEqual(expect.objectContaining({
                id: expect.any(String)
            }));
        }
    });
});
