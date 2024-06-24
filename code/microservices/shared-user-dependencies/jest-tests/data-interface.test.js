
console.log(`resolve modules from [${process.env.NODE_PATH}]`);

const dataInterface = require("../data-interface");

describe(`listUsers`, () => {
    it(`result should not be empty and each should include an id field`, async () => {
        const users = await dataInterface.listUsers();

        expect(users.length).toBeGreaterThan(0);
        
        for (user of users) {
            expect(user).toEqual(expect.objectContaining({
                id: expect.any(String)
            }));
        }
    });
});

describe(`fetchUser`, () => {
    it(`result should not be empty and each should include an id field`, async () => {
        const users = await dataInterface.listUsers();
        const firstUserId = users[0].id;
        const targetUser = await dataInterface.fetchUser(firstUserId);

        expect(targetUser).not.toBeNull();
        expect(targetUser.id).toEqual(firstUserId);
    });
});
