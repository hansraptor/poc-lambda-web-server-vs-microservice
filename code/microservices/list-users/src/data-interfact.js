
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
    }]
};

async function fetchUsers(options = null) {
    return Promise.resolve(usersRepo.users);
};

module.exports = {
    fetchUsers: fetchUsers
}
