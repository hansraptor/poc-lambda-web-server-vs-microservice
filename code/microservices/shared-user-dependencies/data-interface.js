
const uuid = require("uuid4");

const usersRepo = {
    users: [{
        id: uuid(),
        firstName: "John", lastName: "Doe",
        email: "john.doe@lambda.aws", phone: "+00 00 000 0000"
    }, {
        id: uuid(),
        firstName: "Mary", lastName: "Buck",
        email: "mary.buck@lambda.aws", phone: "+00 00 000 0001"
    }, {
        id: "872b923c-5eb3-4ef6-b2bb-58fbb5b20c68",
        firstName: "Piet", lastName: "Pompies",
        email: "piet.pompies@lambda.aws", phone: "+00 00 000 0002"
    }]
};

async function listUsers(options = null) {
    return Promise.resolve(usersRepo.users);
};

async function fetchUser(id) {
    return Promise.resolve(
        usersRepo.users.find(user => user.id == id));
}

module.exports = {
    listUsers: listUsers,
    fetchUser: fetchUser
}
