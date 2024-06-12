
async function annotateUsers(users) {
    if (!users) {
        users = [];
    }

    let userAnnotations = users.map(async (user) => 
        await annotateUser(user))

    return await Promise.all(userAnnotations);
};

async function annotateUser(user) {
    user.readstamp = (new Date()).getTime();

    return Promise.resolve(user);
}

module.exports = {
    annotateUser: annotateUser,
    annotateUsers: annotateUsers
};
