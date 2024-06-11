
const dataInterface = require("../src/data-interfact");

describe(`fetchUsers`, () => {
    it(`result should not be empty`, async () => {
        const users = await dataInterface.fetchUsers();
        
        expect(users.length).toBeGreaterThan(0);
    });
});
