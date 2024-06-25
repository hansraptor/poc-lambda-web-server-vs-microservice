
const index = require("../index");

describe(`createUser`, () => {
    it(`result should have original fields including new id field`, async () => {
        const user = {
            firstName: "Koos", lastName: "de Doos",
            email: "koos.doos@lambda.aws", phone: "+00 00 000 0004"
        };
        const event = {
            body: JSON.stringify(user)
        }
        const context = {};
        const handlerResponse = await index.handler(event, context);

        expect(handlerResponse).not.toBeNull();
        
        const newUser = JSON.parse(handlerResponse.body);
        
        expect(newUser.id).not.toBeNull();
        expect(newUser.id).toEqual(expect.any(String));
        expect(newUser.firstName).toEqual(user.firstName);
        expect(newUser.lastName).toEqual(user.lastName);
        expect(newUser.email).toEqual(user.email);
        expect(newUser.phone).toEqual(user.phone);
    });
});
